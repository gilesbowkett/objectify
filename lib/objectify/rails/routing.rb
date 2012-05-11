require "action_dispatch"

module Objectify
  module Rails
    module Routing
      class ObjectifyMapper
        RESOURCE_ACTIONS = [:index, :show, :create, :update, :destroy].freeze
        OBJECTIFY_OPTIONS = [:policies].freeze
        RAILS_OPTIONS = { :controller => "objectify/rails/controller" }.freeze

        def initialize(rails_mapper, application = Rails.application)
          @rails_mapper = rails_mapper
          @application = application
        end

        def resources(*args)
          options           = args.extract_options!
          objectify_options = extract_objectify_options(options)
          rails_options     = options.merge(RAILS_OPTIONS)

          @rails_mapper.resources(*(args + [rails_options]))
          @application.objectify.append_routes(*(args + [objectify_options]))
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
