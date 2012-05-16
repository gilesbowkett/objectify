require "objectify/config/policies"

module Objectify
  module Config
    class Action
      attr_reader :resource_name, :name, :policies, :service, :responder

      def initialize(resource_name, name, options, default_policies)
        @resource_name = resource_name
        @name = name
        @policies = default_policies.merge(options, options[name])
        @service = options[name][:service]
        @responder = options[name][:responder]
      end
    end
  end
end
