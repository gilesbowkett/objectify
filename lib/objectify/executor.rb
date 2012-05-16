module Objectify
  class Executor
    def initialize(injector, instantiator)
      @injector = injector
      @instantiator = instantiator
    end

    def call(name, type)
      method = type == :policy ? :allowed? : :call
      @injector.call(@instantiator.call(name, type), method)
    end
  end
end
