module Objectify
  class Injector
    def initialize(resolver_locator)
      @resolver_locator = resolver_locator
    end

    def call(object, method)
      method_obj = method_object(object, method)
      arguments = method_obj.parameters.map do |reqd, name|
        call(@resolver_locator.call(name), :call) if reqd == :req
      end
      object.send(method, *arguments)
    end

    private
      def method_object(object, method)
        if method == :new
          object.instance_method(:initialize)
        else
          object.method(method)
        end
      end
  end
end
