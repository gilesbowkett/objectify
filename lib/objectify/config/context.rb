require "objectify/config/policies"

module Objectify
  module Config
    class Context
      attr_reader :policy_responders, :defaults, :actions, :policies

      def initialize(resource_factory = Resource,
                     policies_factory = Policies)
        @resource_factory = resource_factory
        @policies_factory = policies_factory

        @policy_responders = {}
        @defaults = {}
        @actions = {}
      end

      def append_policy_responders(responders)
        @policy_responders.merge!(responders)
      end

      def append_defaults(defaults)
        @policies = @policies_factory.new(defaults)
      end

      def append_action(action)
        @actions[action.route] = action
      end

      def action(route)
        @actions[route] ||
          raise(ArgumentError, "No action matching #{route} was found.")
      end
    end
  end
end
