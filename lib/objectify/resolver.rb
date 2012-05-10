module Objectify
  class NamedValueResolver
    attr_reader :name

    def initialize(name, value)
      @name  = name
      @value = value
    end

    def call
      @value
    end
  end
end
