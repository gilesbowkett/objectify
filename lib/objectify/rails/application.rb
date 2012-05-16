require "objectify/rails/routing"
require "objectify/config/context"

module Objectify
  module Rails
    module Application
      def objectify
        @objectify ||= Config::Context.new
      end

      def routes
        @routes ||= Routing::RouteSet.new
      end
    end
  end
end
