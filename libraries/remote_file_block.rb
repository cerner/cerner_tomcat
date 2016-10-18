# A Block which represents a remote_file resource in the cerner_tomcat LWRP
module CernerTomcat
  class RemoteFileBlock < Block
    attr_reader :file_path

    def initialize(file_path, attribute_name = 'remote_file')
      @file_path = file_path
      @attribute_name = attribute_name
      @mode = '0750'
      @only_if = []
      @not_if = []
    end

    def source(source = nil)
      @source = source unless source.nil?
      @source
    end

    def only_if(command = nil, opts = {}, &block)
      # passed block is stored as a proc
      if command
        @only_if << [command, opts]
      elsif block_given?
        @only_if << block
      end
      @only_if
    end

    def not_if(command = nil, opts = {}, &block)
      # passed block is stored as a proc
      if command
        @not_if << [command, opts]
      elsif block_given?
        @not_if << block
      end
      @not_if
    end

    def mode(mode = nil)
      @mode = mode unless mode.nil?
      @mode
    end

    def evaluate(&block)
      super
      fail "A source attribute is required for #{@attribute_name} [#{file_path}]" unless source
    end
  end
end
