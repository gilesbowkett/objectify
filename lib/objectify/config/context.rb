require "objectify/config/resource"

module Objectify
  module Config
    class Context
      attr_reader :policy_responders, :defaults, :resources

      def initialize(resource_factory = Resource)
        @resource_factory = resource_factory

        @policy_responders = {}
        @defaults = {}
        @resources = {}
      end

      def append_policy_responders(responders)
        @policy_responders.merge!(responders)
      end

      def append_defaults(defaults)
        defaults.each do |k,v|
          if @defaults.has_key?(k)
            @defaults[k] += v
          else
            @defaults[k] = v
          end
        end
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
