module Objectify
  module Config
    class Policies
      attr_reader :policies, :skip_policies

      def initialize(options = {})
        @policies = [*options[:policies]]
        @skip_policies = [*options[:skip_policies]]
      end

      def merge(*others)
        others.inject(@policies - @skip_policies) do |total, opts|
          total + [*opts[:policies]] - [*opts[:skip_policies]]
        end
      end
    end
  end
end
