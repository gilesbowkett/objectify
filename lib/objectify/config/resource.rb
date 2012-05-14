module Objectify
  module Config
    class Resource
      ACTIONS = [:index, :show, :create, :new, :edit, :update, :destroy]

      attr_reader :name, :policies

      def initialize(name, options, policy_config_factory, action_config_factory)
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
    end
  end
end
