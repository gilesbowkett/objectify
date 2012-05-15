module Objectify
  module Config
    class Resolver
      def call(context, parameter, execution_plan)
        initial = [context.send(parameter)]
        execution_plan.steps.inject(initial) do |results,step|
          context = context.child(step)
          results.push(context.send(parameter))
        end
      end
    end
  end
end
