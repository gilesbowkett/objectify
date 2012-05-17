require "objectify/instrumentation"

module Objectify
  class Executor
    include Instrumentation

    def initialize(injector, instantiator)
      @injector = injector
      @instantiator = instantiator
    end

    def call(name, type)
      method = type == :policy ? :allowed? : :call
      opts = { :name => name, :type => type }
      instrument("executor_start.objectify", opts)
      instrument("executor.objectify", opts) do
        @injector.call(@instantiator.call(name, type), method)
      end
    end
  end
end
