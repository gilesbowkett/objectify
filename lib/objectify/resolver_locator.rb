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
  end
end
