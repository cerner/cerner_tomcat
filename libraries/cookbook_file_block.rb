# A Block which represents a cookbook_file resource in the cerner_tomcat LWRP
module CernerTomcat
  class CookbookFileBlock < Block
    attr_reader :file_path

    def initialize(file_path, attribute_name = 'cookbook_file')
      @file_path = file_path
      @attribute_name = attribute_name
    end

    def source(source = nil)
      @source = source unless source.nil?
      @source
    end

    def cookbook(cookbook = nil)
      @cookbook = cookbook unless cookbook.nil?
      @cookbook
    end

    def evaluate(&block)
      super
      fail "A source attribute is required for #{@attribute_name} [#{file_path}]" unless source
    end
  end
end
