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

  class NameTranslationResolver
    attr_reader :name

    def initialize(name, value)
      @name  = name
      @value = value.to_s.classify
    end

    def call
      @value.constantize.new
    end
  end
end
