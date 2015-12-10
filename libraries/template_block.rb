# A Block which represents a template resource in the cerner_tomcat LWRP
module CernerTomcat
  class TemplateBlock < CookbookFileBlock
    def initialize(file_path)
      super(file_path, 'template')
    end

    def variables(variables = nil)
      @variables = variables unless variables.nil?
      @variables
    end
  end
end
