# A Block which represents a remote_file resource in the cerner_tomcat LWRP
module CernerTomcat
  class RemoteFileBlock < Block
    attr_reader :file_path

    def initialize(file_path)
      @file_path = file_path
    end

    def source(source = nil)
      @source = source unless source.nil?
      @source
    end
  end
end
