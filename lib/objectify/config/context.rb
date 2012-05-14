require "objectify/config/resource"
require "objectify/config/policies"

module Objectify
  module Config
    class Context
      attr_reader :policy_responders, :defaults, :resources, :policies

      def initialize(resource_factory = Resource,
                     policies_factory = Policies)
        @resource_factory = resource_factory
        @policies_factory = policies_factory

        @policy_responders = {}
        @defaults = {}
        @resources = {}
      end

      def append_policy_responders(responders)
        @policy_responders.merge!(responders)
      end

      def append_defaults(defaults)
        @policies = @policies_factory.new(defaults)
      end

      def append_resources(*resources)
        options = resources.extract_options!
        resources.each do |resource|
          @resources[resource] = @resource_factory.new(resource, options)
        end
      end
    end
  end
end
