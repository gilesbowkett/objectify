module Objectify
  class ArrayResolverLocator
    def initialize(resolvers)
      @resolvers = resolvers
    end

    def call(name)
      @resolvers.detect { |resolver| resolver.name == name }
    end
  end

  class MultiResolverLocator
    def initialize(locators)
      @locators = locators
    end

    def call(name)
      @locators.each do |locator|
        resolver = locator.call(name)
        return resolver if resolver
      end

      raise ArgumentError, "No resolver found for #{name}."
    end

    def with_context(context)
      @locators.unshift(context)
      yield(self).tap { |r| @locators.shift }
    end
  end

  class NamedValueResolverLocator
    def initialize(resolver_factory = NamedValueResolver)
      @resolver_factory = resolver_factory
      @resolvers        = {}
    end

    def add(name, value)
      @resolvers[name] = @resolver_factory.new(name, value)
    end

    def call(name)
      @resolvers[name]
    end
  end
end
