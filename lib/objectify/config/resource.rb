require "objectify/config/policies"
require "objectify/config/action"

module Objectify
  module Config
    class Resource
      ACTIONS = [:index, :show, :create, :new, :edit, :update, :destroy]

      attr_reader :name, :policies

      def initialize(name, options,
                     policy_config_factory = Policies,
                     action_config_factory = Action)
        @name = name
        @policies = policy_config_factory.new(options)
        @actions = ACTIONS.inject({}) do |configs, action|
          opts = options[action]
          configs[action] = action_config_factory.new(action, opts)
          configs
        end
      end

      def action(name)
        @actions[name]
      end

      def child(step)
        step.type == :action ||
          raise(ArgumentError, "No children of type #{type}.")

        name = step.name
        @actions[name] ||
          raise(ArgumentError, "Can't find an action named #{name}.")
      end
    end
  end
end
