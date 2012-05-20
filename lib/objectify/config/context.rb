require "objectify/config/action"
require "objectify/config/policies"
require "objectify/injector"
require "objectify/instantiator"
require "objectify/resolver"
require "objectify/resolver_locator"
require "objectify/executor"

module Objectify
  module Config
    class Context
      attr_reader :policy_responders, :defaults, :actions, :policies
      attr_writer :injector, :resolver_locator, :instantiator, :executor,
                  :locator, :objectify_controller

      def initialize(policies_factory = Policies, action_factory = Action)
        @policies_factory = policies_factory
        @action_factory   = action_factory

        @policy_responders = {}
        @defaults = {}
        @actions = {}
      end

      def append_policy_responders(responders)
        @policy_responders.merge!(responders)
      end

      def policy_responder(policy)
        @policy_responders[policy] ||
          raise(ArgumentError, "Can't find a responder for #{policy}.")
      end

      def policies
        @policies ||= @policies_factory.new
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

      def legacy_action(route)
        @actions[route] ||
          @action_factory.new(route.resource, route.action, {}, policies)
      end

      def injector
        @injector ||= Injector.new(resolver_locator)
      end

      def append_resolutions(opts)
        opts.each do |k,v|
          locator.add(k, v)
        end
      end

      def locator
        @locator ||= NamedValueResolverLocator.new(NameTranslationResolver)
      end

      def resolver_locator
        @resolver_locator ||= MultiResolverLocator.new(
                                [locator, ConstResolverLocator.new]
                              )
      end

      def instantiator
        @instantiator ||= Instantiator.new(injector)
      end

      def executor
        @executor ||= Executor.new(injector, instantiator)
      end

      def objectify_controller
        @objectify_controller ||= "objectify/rails/objectify"
      end

      def reload
        instance_variables.each do |name|
          instance_variable_set(name, nil)
        end
      end
    end
  end
end
