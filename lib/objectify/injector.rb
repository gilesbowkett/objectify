require "objectify/instrumentation"

module Objectify
  class Injector
    include Instrumentation

    def initialize(resolver_locator)
      @resolver_locator = resolver_locator
    end

    def call(object, method)
      payload = {:object => object, :method => method}
      instrument("inject.objectify", payload) do |payload|
        method_obj           = method_object(object, method)
        resolvers            = method_obj.parameters.map do |reqd, name|
          @resolver_locator.call(name) if reqd == :req
        end
        arguments            = resolvers.map do |resolver|
          call(resolver, :call)
        end

        payload[:parameters] = method_obj.parameters
        payload[:resolvers]  = resolvers
        payload[:arguments]  = arguments

        object.send(method, *arguments)
      end
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
