require "objectify/resolver_locator"
require "objectify/executor"
require "objectify/policy_chain_executor"

module Objectify
  module Rails
    module ControllerBehaviour
      def method_missing(name, *args, &block)
        route = Objectify::Route.new(params[:objectify][:resource].to_sym, params[:action].to_sym)
        action = objectify.action(route)

        objectify.resolver_locator.with_context(request_resolver) do
          respond_to do |format|
            request_resolver.add(:format, format)

            if executor.call(policy, :policy)
              service_result = executor.call(action.service, :service)
              request_resolver.add(:service_result, service_result)
            end

            executor.call(action.responder, :responder)
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
          klass = Objectify::NamedValueResolverLocator
          @request_resolver ||= klass.new.tap do |resolver|
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

    class Controller < ActionController::Base
      include ControllerBehaviour
    end
  end
end
