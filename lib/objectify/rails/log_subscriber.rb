require "active_support/all"

module Objectify
  module Rails
    class LogSubscriber < ActiveSupport::LogSubscriber
      def start_processing(event)
        logger.debug("    [Objectify] Started #{event.payload[:route]}")
      end

      def inject(event)
        if logger.debug?
          object     = event.payload[:object]
          method     = event.payload[:method]
          parameters = event.payload[:parameters].map do |req, param|
            param if req == :req
          end.compact
          resolvers  = Hash[*parameters.zip(event.payload[:resolvers].map(&:class)).flatten]
          arguments  = event.payload[:arguments].map(&:class).inspect[1..-2]

          message = "      [Injector] Invoking #{object}.#{method}(#{arguments}). "
          message << "Resolutions: #{resolvers}. " if !resolvers.empty?
          message << duration(event)

          logger.debug(message)
        end
      end

      def executor_start(event)
        if logger.debug?
          type = event.payload[:type].to_s.capitalize
          logger.debug("    [#{type}] Executing #{event.payload[:name]} " + duration(event))
        end
      end

      def executor(event)
        if logger.debug?
          type = event.payload[:type].to_s.capitalize
          logger.debug("    [#{type}] Executed #{event.payload[:name]} " + duration(event))
        end
      end

      def policy_chain_halted(event)
        if logger.debug?
          logger.debug("    [Policy] Chain halted at #{event.payload[:policy]}. Responding with #{event.payload[:responder]}." + duration(event))
        end
      end

      def logger
        ::Rails.logger
      end

      def duration(event)
        "#{"(%.1fms)" % event.duration}"
      end
    end
  end
end

Objectify::Rails::LogSubscriber.attach_to(:objectify)
