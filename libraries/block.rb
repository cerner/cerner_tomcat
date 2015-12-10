# A block represents a Ruby Block that will be evaluated. This is used for defining different parts
# of cerner_tomcat resource and is the same method Chef uses for describing its resources
module CernerTomcat
  class Block
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
