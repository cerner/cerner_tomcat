# A Block which represents a web_app resource in the cerner_tomcat LWRP
module CernerTomcat
  class WebAppBlock < Block
    attr_reader :name, :cookbook_files, :remote_files, :templates

    def initialize(name)
      @name = name
      @cookbook_files = []
      @remote_files = []
      @templates = []
    end

    def source(source = nil)
      @source = source unless source.nil?
      @source
    end

    def checksum(checksum = nil)
      @checksum = checksum unless checksum.nil?
      @checksum
    end

    def cookbook_file(file_path, &block)
      cookbook_file_block = CookbookFileBlock.new(file_path)
      cookbook_file_block.evaluate(&block)
      @cookbook_files << cookbook_file_block
    end

    def remote_file(file_path, &block)
      remote_file_block = RemoteFileBlock.new(file_path)
      remote_file_block.evaluate(&block)
      @remote_files << remote_file_block
    end

    def template(file_path, &block)
      template_block = TemplateBlock.new(file_path)
      template_block.evaluate(&block)
      @templates << template_block
    end

    def evaluate(&block)
      super
      fail "A source attribute is required for web_app [#{name}]" unless source
    end
  end
end
