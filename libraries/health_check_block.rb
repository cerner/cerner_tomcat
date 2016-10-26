# A Block which represents a health_check resource in the cerner_tomcat LWRP
module CernerTomcat
  class HealthCheckBlock < Block
    attr_reader :uri, :http_method, :backoff, :time_bound, :args

    def initialize(uri)
      @uri = uri
      @http_method = 'GET'
      @backoff = [0, 5, 10, 30, 30, 60] # In seconds
      @time_bound = 3 # In seconds
    end

    def uri(uri = nil)
      @uri = uri unless uri.nil?
      @uri
    end

    def http_method(http_method = nil)
      @http_method = http_method unless http_method.nil?
      @http_method
    end

    def backoff(backoff = nil)
      @backoff = backoff unless backoff.nil?
      @backoff
    end

    def time_bound(time_bound = nil)
      @time_bound = time_bound unless time_bound.nil?
      @time_bound
    end

    def args(args = nil)
      @args = args unless args.nil?
      @args
    end
  end
end
