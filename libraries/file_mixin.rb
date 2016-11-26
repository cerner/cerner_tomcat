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

require 'poise/utils'

module CernerTomcat
  module FileMixin
    include Poise::Utils::ResourceProviderMixin

    module Resource
      include Poise::Resource

      # Set the parent type and optional flag.
      poise_subresource(:cerner_tomcat, true)

      def initialize(*)
        super
        # So our lazy default below can work. Not needed on 12.7+.
        remove_instance_variable(:@path) if instance_variable_defined?(:@path)
        remove_instance_variable(:@sensitive) if instance_variable_defined?(:@sensitive)
      end

      # Method called indicating if the last action called on this resource resulted in an update
      def updated_by_last_action(true_or_false)
        super
        # If this file has been updated, notify our parent that a restart is required
        notifies :restart, parent if updated?
      end

      attribute(:path, kind_of: String, default: lazy { parent ? ::File.join(parent.base_dir, parent.instance_name, name) : name })

      attribute(:group, kind_of: [String, Integer, NilClass], default: lazy { parent && parent.group })

      attribute(:owner, kind_of: [String, Integer, NilClass], default: lazy { parent && parent.user })

      attribute(:sensitive, kind_of: [TrueClass, FalseClass], default: lazy { parent ? parent.sensitive : true})
    end

    module Provider
      include Poise::Provider

      def run_action(action = nil)
        # create the parent directory for the file, if necessary
        unless ::File.directory?(::File.dirname(new_resource.path))
          dir = Chef::Resource::Directory.new(::File.dirname(new_resource.path), run_context)
          dir.group(new_resource.group) if new_resource.group
          dir.owner(new_resource.owner) if new_resource.owner
          dir.sensitive new_resource.sensitive
          dir.recursive(true)
          dir.run_action(:create)
        end
        super
      end
    end
  end
end
