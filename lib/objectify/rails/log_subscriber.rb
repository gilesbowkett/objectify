require "active_support/all"

module Objectify
  module Rails
    class LogSubscriber < ActiveSupport::LogSubscriber
      def inject(event)
        if logger.debug?
          object     = event.payload[:object]
          method     = event.payload[:method]
          parameters = event.payload[:parameters].map do |req, param|
            param if req == :req
          end.compact
          resolvers  = Hash[*parameters.zip(event.payload[:resolvers].map(&:class)).flatten]
          arguments  = event.payload[:arguments].map(&:class).inspect[1..-2]

          message = "    [Injector] Invoking #{object}.#{method}(#{arguments}). "
          message << "Resolutions: #{resolvers}. " if !resolvers.empty?
          message << "#{"(%.1fms)" % event.duration}"

          logger.debug(message)
        end
      end

      def logger
        ::Rails.logger
      end
    end
  end
end

Objectify::Rails::LogSubscriber.attach_to(:objectify)
