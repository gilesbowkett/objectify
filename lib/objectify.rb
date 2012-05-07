module Objectify
  class Injector
    def initialize(resolvers)
      @resolvers = resolvers
    end

    def call(object, method)
      method_obj = object.instance_method(:initialize)
      arguments = method_obj.parameters.map do |reqd, name|
        resolver_for(name).call
      end
      object.send(method, *arguments)
    end

    private
      def resolver_for(name)
        @resolvers.detect { |r| r.name == name }
      end
  end
end
