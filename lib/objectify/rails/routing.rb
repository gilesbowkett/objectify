module Objectify
  module Rails
    module Routing
      class ObjectifyMapper
        RESOURCE_ACTIONS = [:index, :show, :create, :update, :destroy].freeze
        OBJECTIFY_OPTIONS = [:policies].freeze

        def initialize(rails_mapper, application = Rails.application)
          @rails_mapper = rails_mapper
          @application = application
        end

        def resources(*args)
          options           = args.extract_options!
          objectify_options = extract_objectify_options(options)
          rails_options     = options.merge(:controller => :objectify)

          @rails_mapper.resources(*(args + [rails_options]))
          @application.objectify.append_routes(*(args + [objectify_options]))
        end

        private
          def extract_objectify_options(options)
            Hash[*(RESOURCE_ACTIONS + OBJECTIFY_OPTIONS).map do |key|
              [key, options.delete(key)] if options.include?(key)
            end.compact.flatten]
          end
      end
    end
  end
end
