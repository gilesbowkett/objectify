require "active_support/all"

module Objectify
  module Instrumentation
    private
      def instrument(name, payload={})
        ActiveSupport::Notifications.instrument(name, payload) do |payload|
          yield(payload) if block_given?
        end
      end
  end
end
