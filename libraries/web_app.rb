#
# Copyright 2013 Cerner Innovation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'poise'
require_relative 'file_mixin'

module CernerTomcat
  module Resources
    module WebApp
      class Resource < Chef::Resource
        include Poise::Resource
        provides(:cerner_tomcat_web_app)

        # Set the parent type and optional flag.
        poise_subresource(:cerner_tomcat, true)

        actions(:create)

        attribute :source, kind_of: String, required: true
        attribute :checksum, kind_of: String

        def initialize(*args)
          super
          # For older Chef (<12.4)
          @resource_name = :cerner_tomcat_web_app

          @cookbook_files = {}
          @remote_files = {}
          @templates = {}
        end

        attr_reader :cookbook_files, :remote_files, :templates

        def cookbook_file(file_path, &block)
          @cookbook_files.store(file_path, block)
        end

        def remote_file(file_path, &block)
          @remote_files.store(file_path, block)
        end

        def template(file_path, &block)
          @templates.store(file_path, block)
        end

        action(:create) do
          notifying_block do
	    web_app_dir = ::File.join(parent.base_dir, parent.instance_name, 'webapps', new_resource.name)

	    war_file_path = "#{web_app_dir}.war"

	    # Download war file
	    remote_file war_file_path do
	      source new_resource.source
	      owner parent.user
	      group parent.group
	      checksum new_resource.checksum if new_resource.checksum
	      mode '0755'
	      backup false
              notifies :stop, new_resource.parent, :before
	      notifies :delete, "directory[#{web_app_dir}]", :immediately
              notifies :restart, new_resource.parent
	    end

	    directory web_app_dir do
	      owner parent.user
	      group parent.group
	      mode '0755'
              recursive true
	    end

	    # Explode war
	    execute "jar xf #{war_file_path}" do
	      cwd web_app_dir
              user parent.user
              group parent.group
	      only_if do
		Dir.entries(web_app_dir).delete_if { |v| v == '.' || v == '..' }.empty?
	      end
	    end

	    # Install any webapp cookbook files
	    new_resource.cookbook_files.each do |file_path, block|
              cerner_tomcat_cookbook_file ::File.join('webapps', new_resource.name, file_path) do
                parent new_resource.parent
                instance_eval(&block) if block
              end
	    end

	    # Install any webapp remote files
	    new_resource.remote_files.each do |file_path, block|
	      cerner_tomcat_remote_file ::File.join('webapps', new_resource.name, file_path) do
                parent new_resource.parent
                instance_eval(&block) if block
              end
	    end

	    # Install any webapp templates
	    new_resource.templates.each do |file_path, block|
	      cerner_tomcat_template ::File.join('webapps', new_resource.name, file_path) do
                parent new_resource.parent
                instance_eval(&block) if block
              end
	    end
          end
        end
      end
    end
  end
end
