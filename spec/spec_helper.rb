require 'chefspec'
require 'chefspec/berkshelf'

require_relative '../libraries/health_check.rb'

at_exit { ChefSpec::Coverage.report! }
