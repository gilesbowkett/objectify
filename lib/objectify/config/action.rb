require "objectify/config/policies"

module Objectify
  module Config
    class Action
      attr_reader :name, :policies, :service, :responder

      def initialize(name, options, policy_config_factory = Policies.new)
        @name = name
        @policies = policy_config_factory.new(options)
        @service = options[:service]
        @responder = options[:responder]
      end
    end
  end
end
