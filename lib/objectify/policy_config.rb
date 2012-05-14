module Objectify
  class PolicyConfig
    attr_reader :policies, :skip_policies

    def initialize(options)
      @policies = [*options[:policies]]
      @skip_policies = [*options[:skip_policies]]
    end

    def resolve
      @policies - @skip_policies
    end

    def merge(other)
      self.class.new :policies => resolve + other.resolve
    end
  end
end
