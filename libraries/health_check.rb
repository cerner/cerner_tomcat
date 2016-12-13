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

module CernerTomcat
  class HealthCheckBlock
    attr_reader :uri, :http_method, :backoff, :time_bound, :args

    def initialize(uri)
      @uri = uri
      @http_method = 'GET'
      @backoff = [0, 5, 10, 30, 30, 60] # In seconds
      @time_bound = 3 # In seconds
    end

    def uri(uri = nil)
      @uri = uri if uri
      @uri
    end

    def http_method(http_method = nil)
      @http_method = http_method if http_method
      @http_method
    end

    def backoff(backoff = nil)
      @backoff = backoff if backoff
      @backoff
    end

    def time_bound(time_bound = nil)
      @time_bound = time_bound if time_bound
      @time_bound
    end

    def args(args = nil)
      @args = args if args
      @args
    end

    def evaluate(&block)
      # If consumers do not provide a do block, &block can be nil
      unless block.nil?
        @self_before_instance_eval = eval 'self', block.binding
        instance_eval(&block)
      end
    end

    def method_missing(m, *args, &block)
      @self_before_instance_eval.send m, *args, &block
    end
  end
end
