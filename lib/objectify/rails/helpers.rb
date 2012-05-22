module Objectify
  module Rails
    module Helpers
      def objectify_data
        @_objectify_data ||
          raise(ArgumentError, "No data was passed to this view.")
      end

      def policy_allowed?(policy_name)
        objectify_executor.call(policy_name, :policy)
      end
    end
  end
end
