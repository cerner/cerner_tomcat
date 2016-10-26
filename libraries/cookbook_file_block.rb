# Required due to chef loading files in alphabetical order. This will hopefully get addressed
# with https://github.com/chef/chef-rfc/blob/master/rfc040-on-demand-cookbook-libraries.md
require_relative 'remote_file_block'

# A Block which represents a cookbook_file resource in the cerner_tomcat LWRP
module CernerTomcat
  class CookbookFileBlock < RemoteFileBlock
    def initialize(file_path, attribute_name = 'cookbook_file')
      super(file_path, attribute_name)
    end

    def cookbook(cookbook = nil)
      @cookbook = cookbook unless cookbook.nil?
      @cookbook
    end
  end
end
