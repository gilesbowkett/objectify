require "objectify/rails/routing"

module Objectify
  module Rails
    module Application
      def objectify
        @objectify ||= Context.new
      end

      def routes
        @routes ||= RouteSet.new
      end
    end
  end
end
