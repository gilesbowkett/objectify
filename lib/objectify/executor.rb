module Objectify
  class Executor
    def initialize(injector, instantiator)
      @injector = injector
      @instantiator = instantiator
    end

    def call(name, type)
      @injector.call(@instantiator.call(name, type), :call)
    end
  end
end
