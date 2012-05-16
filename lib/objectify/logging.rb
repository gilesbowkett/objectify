require "logger"

module Objectify
  module Logging
    class << self
      attr_writer :logger

      def logger
        @logger ||= Logger.new("/dev/null")
      end
    end

    private
      def logger
        if Kernel.const_defined?(:Rails)
          ::Rails.logger
        else
          Logging.logger
        end
      end
  end
end
