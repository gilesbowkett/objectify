require "objectify/instrumentation"

module Objectify
  class PolicyChainExecutor
    include Instrumentation

    def initialize(executor, context)
      @executor = executor
      @context  = context
    end

    def call(action)
      action.policies.each do |policy|
        if !@executor.call(policy, :policy)
          responder = @context.policy_responder(policy)
          instrument("policy_chain_halted.objectify", :policy    => policy,
                                                      :responder => responder)
          @executor.call(responder, :responder)

          return false
        end
      end

      true
    end
  end
end
