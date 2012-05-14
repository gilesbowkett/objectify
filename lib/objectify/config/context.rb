module Objectify
  module Config
    class Context
      attr_reader :policy_responders, :defaults, :routes

      def initialize
        @policy_responders = {}
        @defaults = {}
        @routes = {}
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

      def append_routes(*routes)
        options = routes.extract_options!
        routes.each do |resource|
          @routes[resource] = options
        end
      end
    end
  end
end
