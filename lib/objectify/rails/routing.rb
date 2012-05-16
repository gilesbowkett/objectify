require "action_dispatch"
require "objectify/config/action"

module Objectify
  module Rails
    module Routing
      RESOURCE_ACTIONS = [:index, :show, :new, :create,
                          :edit, :update, :destroy].freeze
      OBJECTIFY_OPTIONS = [:policies].freeze

      class ObjectifyMapper
        RAILS_OPTIONS = {
          :controller => "objectify/rails/objectify"
        }.freeze

        def initialize(rails_mapper,
                       application = ::Rails.application,
                       action_factory = Config::Action)
          @rails_mapper = rails_mapper
          @application = application
          @action_factory = action_factory
        end

        def resources(*args)
          options           = args.extract_options!
          objectify_options = extract_objectify_options(options)
          rails_options     = options.merge(RAILS_OPTIONS)

          args.each do |resource_name|
            objectify_defaults = {:objectify => {:resource => resource_name}}
            defaults = (rails_options[:defaults] || {}).merge(objectify_defaults)
            with_defaults = rails_options.merge(:defaults => defaults)
            @rails_mapper.resources(resource_name, with_defaults)

            RESOURCE_ACTIONS.each do |action_name|
              action = @action_factory.new(resource_name,
                                           action_name,
                                           objectify_options,
                                           @application.objectify.policies)

              @application.objectify.append_action(action)
            end
          end
        end

        def defaults(options)
          @application.objectify.append_defaults(options)
        end

        def policy_responders(options)
          @application.objectify.append_policy_responders(options)
        end

        private
          def extract_objectify_options(options)
            Hash[*(RESOURCE_ACTIONS + OBJECTIFY_OPTIONS).map do |key|
              [key, options.delete(key)] if options.include?(key)
            end.compact.flatten]
          end
      end

      class Mapper < ActionDispatch::Routing::Mapper
        def objectify
          @objectify ||= ObjectifyMapper.new(self)
        end
      end

      class RouteSet < ActionDispatch::Routing::RouteSet
        def draw(&block)
          clear! unless @disable_clear_and_finalize

          mapper = Mapper.new(self)
          if block.arity == 1
            mapper.instance_exec(ActionDispatch::Routing::DeprecatedMapper.new(self), &block)
          else
            mapper.instance_exec(&block)
          end

          finalize! unless @disable_clear_and_finalize

          nil
        end
      end
    end
  end
end
