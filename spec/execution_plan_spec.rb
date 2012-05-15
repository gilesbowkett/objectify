require "spec_helper"
require "objectify/execution_plan"

describe "Objectify::ExecutionPlan" do
  before do
    @opts = {
      :resource => :pictures,
      :action => :index
    }
    @step_factory = stub("StepFactory")
    @resource_step = stub("ResourceStep")
    @action_step = stub("ActionStep")
    @step_factory.stubs(:new).with(:resource, :pictures).
      returns(@resource_step)
    @step_factory.stubs(:new).with(:action, :index).returns(@action_step)

    @plan = Objectify::ExecutionPlan.new(@opts, @step_factory)
  end

  it "creates steps based on the params" do
    @plan.steps.should == [@resource_step, @action_step]
  end
end
