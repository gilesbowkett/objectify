module Objectify
  class Injector
    def initialize(resolvers)
      @resolvers = resolvers
    end

    def call(object, method)
      method_obj = method_object(object, method)
      arguments = method_obj.parameters.map do |reqd, name|
        call(resolver_for(name), :call) if reqd == :req
      end
      object.send(method, *arguments)
    end

    private
      def resolver_for(name)
        @resolvers.detect { |r| r.name == name }
      end

      def method_object(object, method)
        if method == :new
          object.instance_method(:initialize)
        else
          object.method(method)
        end
      end
  end
end
