module Objectify
  class PolicyChainExecutor
    def initialize(executor, context)
      @executor = executor
      @context  = context
    end

    def call(action)
      action.policies.each do |policy|
        if !@executor.call(policy, :policy)
          responder = @context.policy_responder(policy)
          @executor.call(responder, :responder)

          return false
        end
      end

      true
    end
  end
end
