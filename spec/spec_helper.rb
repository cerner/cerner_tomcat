require 'chefspec'
require 'chefspec/berkshelf'

require_relative '../libraries/block.rb'
require_relative '../libraries/cookbook_file_block.rb'
require_relative '../libraries/health_check_block.rb'
require_relative '../libraries/remote_file_block.rb'
require_relative '../libraries/template_block.rb'
require_relative '../libraries/web_app_block.rb'

at_exit { ChefSpec::Coverage.report! }
