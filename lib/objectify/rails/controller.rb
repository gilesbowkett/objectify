module Objectify
  module Rails
    module Controller
      def method_missing(name, *args, &block)
        objectify.resolver_locator.with_context(request_resolver) do
          if executor.call(policy, :policy)
            service_result = executor.call(action.service, :service)
            request_resolver.add(:service_result, service_result)

            respond_to do |format|
              request_resolver.add(:format, format)
              executor.call(action.responder, :responder)
            end
          end
        end
      end

      private
        def objectify
          Rails.application.objectify
        end

        def injector
          objectify.injector
        end

        def request_resolver
          @request_resolver ||= Objectify::NamedValueResolver.new.tap do |resolver|
            resolver.add(:controller, self)
            resolver.add(:params, params)
          end
        end
        
        def executor
          @executor ||= Objectify::Executor.new(injector)
        end

        def policy_chain_executor
          @policy_chain_executor ||= Objectify::PolicyChainExecutor.new(executor)
        end
    end
  end
end
