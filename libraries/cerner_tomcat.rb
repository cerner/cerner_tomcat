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
require 'poise_service'

module CernerTomcat
  module Resources
    module Tomcat
      class Resource < Chef::Resource
        include Poise(container: true, container_namespace: false)
        provides(:cerner_tomcat)
        include PoiseService::ServiceMixin

        def initialize(*args)
          super

          @health_checks = []

          # so our default below can work.
          remove_instance_variable(:@sensitive) if instance_variable_defined?(:@sensitive)

          _rewire_sub_resources! if node
        end

        attr_reader :health_checks

        def health_check(uri, &block)
          health_check_block = ::CernerTomcat::HealthCheckBlock.new(uri)
          health_check_block.evaluate(&block)
          @health_checks << health_check_block
        end

        attribute :instance_name, kind_of: String, name_attribute: true
        attribute :user, kind_of: String, default: 'tomcat'
        attribute :group, kind_of: String, default: 'tomcat'
        attribute :base_dir, kind_of: String, default: '/opt/tomcat'
        attribute :log_dir, kind_of: String, default: '/var/log/tomcat'
        attribute :log_rotate_options, option_collector: true, default: lazy { default_log_rotate_options }
        attribute :version, kind_of: String, default: '8.0.21'
        attribute :tomcat_url, kind_of: String, default: lazy { default_tomcat_url }
        attribute :shutdown_timeout, kind_of: Integer, default: 60
        attribute :java_settings, kind_of: Hash, default: {}
        attribute :env_vars, kind_of: Hash, default: {}
        attribute :init_info, option_collector: true, default: lazy { default_init_info }
        attribute :install_java, equal_to: [true, false], default: true
        attribute :limits, option_collector: true, default: { 'open_files' => 32_768, 'max_processes' => 1024 }
        attribute :create_user, equal_to: [true, false], default: false
        attribute :sensitive, equal_to: [true, false], default: true
        attribute :service_manager, equal_to: [:sysvinit, :upstart], default: :sysvinit

        def install_dir
          ::File.join(base_dir, instance_name)
        end

        def command
          "#{install_dir}/bin/catalina.sh run"
        end

        def default_log_rotate_options
          {
            'path' => [],
            'frequency' => 'daily',
            'rotate' => 3,
            'options' => %w(notifempty copytruncate compress),
            'size' => '10M',
            'maxsize' => '100M'
          }
        end

        def default_init_info
          {
            'Default-Start' => '3 4 5',
            'Default-Stop' => '0 1 2 6',
            'Required-Start' => '',
            'Required-Stop' => '',
            'Should-Start' => '',
            'Should-Stop' => ''
          }
        end

        def default_tomcat_url
          "http://repo1.maven.org/maven2/org/apache/tomcat/tomcat/#{version}/tomcat-#{version}.tar.gz"
        end

        private

        # Rewire our cerner_tomcat sub-resources so they dont require the cerner_tomcat_ prefix
        def _rewire_sub_resources!
          rewire_map = {
            'remote_file' => 'cerner_tomcat_remote_file',
            'template' => 'cerner_tomcat_template',
            'cookbook_file' => 'cerner_tomcat_cookbook_file',
            'web_app' => 'cerner_tomcat_web_app'
          }
          # Generate stub methods for all the rewiring.
          rewire_map.each do |new_name, old_name|
            # This is defined as a singleton method on self so it looks like
            # the DSL but is scoped to just this context.
            define_singleton_method(new_name) do |name=nil, *args, &block|
              # Store the caller to correct the source_line.
              created_at = caller[0]
              public_send(old_name, name, *args) do
                # Set the declared type to be the native name.
                self.declared_type = self.class.resource_name
                # Fix the source location. for chef 12.4 we could do this with the
                # declared_at parameter on the initial send.
                self.source_line = created_at
                # Run the original block.
                instance_exec(&block) if block
              end
            end
          end
        end
      end

      class Provider < Chef::Provider
        include Poise
        provides(:cerner_tomcat)
        include PoiseService::ServiceMixin

        def action_enable
          notifying_block do
            log_dir = ::File.join(new_resource.log_dir, new_resource.instance_name)
            tomcat_url = new_resource.tomcat_url
            tomcat_file = "cerner_tomcat_#{new_resource.instance_name}-apache-tomcat.tar.gz"

            # Install java
            run_context.include_recipe 'java' if new_resource.install_java

            # Ensure curl is installed if we have any health checks
            package "curl_#{new_resource.instance_name}" do
              action :install
              package_name 'curl'
              not_if { new_resource.health_checks.empty? }
            end

            # Setup user/group
            poise_service_user "#{new_resource.instance_name} user" do
              user new_resource.user
              group new_resource.group
              only_if { new_resource.create_user }
            end

            ulimits = new_resource.limits
            user_ulimit new_resource.user do
              filehandle_limit ulimits['open_files']
              process_limit ulimits['max_processes']
            end

            # From the requirements of the cookbook:
            # If you're on Ubuntu, you'll also need to add recipe[ulimit] to your
            # runlist, or the files created by this cookbook will be ignored
            run_context.include_recipe 'ulimit' if platform_family?('ubuntu')

            # Create base directory
            directory new_resource.base_dir do
              action :create
              owner new_resource.user
              group new_resource.group
              mode '0755'
              recursive true
            end

            remote_file "#{Chef::Config[:file_cache_path]}/#{tomcat_file}" do
              source tomcat_url
              owner new_resource.user
              group new_resource.group
              mode '0755'
              backup false
              notifies :stop, new_resource, :immediately
              notifies :unpack, "poise_archive[#{tomcat_file}]", :immediately
            end

            web_app_dir = ::File.join(new_resource.install_dir, 'webapps')

            # Install tomcat
            poise_archive tomcat_file do
              action :nothing
              destination new_resource.install_dir
              user new_resource.user
              group new_resource.group
              notifies :delete, "directory[#{web_app_dir}]", :immediately
              notifies :restart, new_resource
            end

            directory web_app_dir do
              owner new_resource.user
              group new_resource.group
              mode '0755'
              recursive true
            end

            directory new_resource.log_dir do
              owner new_resource.user
              group new_resource.group
              mode '0755'
              recursive true
            end

            # Link tomcat log files into /var/log/tomcat/[instanceName]
            link log_dir do
              to "#{new_resource.install_dir}/logs"
              owner new_resource.user
              group new_resource.group
              mode '0755'
            end

            # Ensure the right paths are always added
            log_rotate_options = new_resource.log_rotate_options
            log_rotate_options['path'] += ["#{log_dir}/*.out", "#{log_dir}/*.log"]

            # Add log rotate config for tomcat
            logrotate_app "tomcat-#{new_resource.instance_name}" do
              log_rotate_options.each do |k, v|
                send k, v
              end
            end

            # Configure environment vars and java settings
            template "#{new_resource.install_dir}/bin/setenv.sh" do
              source 'setenv.sh.erb'
              cookbook 'cerner_tomcat'
              mode '0755'
              backup false
              sensitive new_resource.sensitive
              owner new_resource.user
              group new_resource.group
              variables(
                env_vars: new_resource.env_vars,
                java_settings: new_resource.java_settings
              )
              notifies :restart, new_resource
            end
          end
          super
        end

        def action_disable
          # Since we are recursively deleting directories guard against empty string which
          # could result in deleting more than what we want
          fail 'base_dir cannot be empty string' if new_resource.base_dir.empty?
          fail 'instance_name cannot be empty string' if new_resource.instance_name.empty?
          fail 'log_dir cannot be empty string' if new_resource.log_dir.empty?

          super
          notifying_block do
            directory "#{new_resource.base_dir}/#{new_resource.instance_name}" do
              action :delete
              recursive true
            end

            file "#{new_resource.log_dir}/#{new_resource.instance_name}" do
              action :delete
            end
          end
        end

        def service_options(service)
          service.command(new_resource.command)
          service.directory(new_resource.install_dir)
          service.user(new_resource.user)
          service.environment( { 'CATALINA_HOME' => new_resource.install_dir } )
          service.options(
            :cerner_tomcat_sysvinit,
            template: 'cerner_tomcat:tomcat_init.sh.erb',
            script_path: "/etc/init.d/tomcat_#{new_resource.instance_name}"
          )
          service.options(
            :cerner_tomcat_upstart,
            template: 'cerner_tomcat:upstart.conf.erb'
          )
          service.provider("cerner_tomcat_#{new_resource.service_manager}".to_sym)
        end
      end
    end
  end
end
