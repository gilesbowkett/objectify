module Objectify
  class ExecutionPlan
    class Step < Struct.new(:type, :name); end

    attr_accessor :steps, :policies, :service, :responder

    def initialize(params, step_factory = Step)
      @steps = []
      @steps << step_factory.new(:resource, params[:resource])
      @steps << step_factory.new(:action, params[:action])
    end
  end
end
