require "objectify/resolver"

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
      @locators = [*locators]
    end

    def call(name)
      @locators.each do |locator|
        resolver = locator.call(name)
        return resolver if resolver
      end

      raise ArgumentError, "No resolver found for #{name}."
    end

    def context(context)
      @locators.unshift(context)
    end

    def clear_context
      @locators.shift
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

  class ConstResolverLocator
    def initialize
      @cache = {}
    end

    def call(name)
      @cache[name] || locate_and_store(name)
    end

    private
      def locate_and_store(name)
        begin
          [name, :resolver].join("_").classify.constantize.new.tap do |obj|
            @cache[name] = obj
          end
        rescue NameError
        end
      end
  end
end
