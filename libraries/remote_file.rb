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

require_relative 'file_mixin'

module CernerTomcat
  module Resources
    module RemoteFile
      class Resource < Chef::Resource::RemoteFile
        include CernerTomcat::FileMixin
        provides(:cerner_tomcat_remote_file)
        actions(:create, :create_if_missing, :delete, :touch)

        def initialize(*args)
          super
          @provider = CernerTomcat::Resources::RemoteFile::Provider
          # For older Chef (< 12.4)
          @resource_name = :cerner_tomcat_remote_file
        end
      end

      class Provider < Chef::Provider::RemoteFile
        include CernerTomcat::FileMixin
      end
    end
  end
end
