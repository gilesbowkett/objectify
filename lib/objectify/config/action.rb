require "objectify/config/policies"
require "objectify/route"

module Objectify
  module Config
    class Action
      attr_reader :resource_name, :name, :route, :policies, :service, :responder

      def initialize(resource_name, name, options, default_policies,
                     route_factory = Route)
        @route = route_factory.new(resource_name, name)
        @resource_name = resource_name
        @name = name
        @policies = default_policies.merge(options, options[name])

        if options[name]
          @service = options[name][:service]
          @responder = options[name][:responder]
        end
      end

      def service
        @service ||= [resource_name, name].join("_").to_sym
      end

      def responder
        @responder ||= [resource_name, name].join("_").to_sym
      end
    end
  end
end
