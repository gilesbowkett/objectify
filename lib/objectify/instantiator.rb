require "active_support/all"

module Objectify
  class Instantiator
    def initialize(injector)
      @injector = injector
    end

    def call(name, type)
      klass = [name, type].join("_").classify.constantize
      @injector.call(klass, :new)
    end
  end
end
