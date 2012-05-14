module Objectify
  module Config
    class Policies
      attr_reader :policies, :skip_policies

      def initialize(options)
        @policies = [*options[:policies]]
        @skip_policies = [*options[:skip_policies]]
      end

      def merge(other)
        self.class.new(:policies => @policies - @skip_policies +
                                      other.policies - other.skip_policies)
      end
    end
  end
end
