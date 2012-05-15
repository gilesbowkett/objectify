require "spec_helper"
require "objectify/config/resolver"

describe "Objectify::Config::Resolver" do
  before do
    @level_two = stub("LevelTwo", :policies => :level_two_policies)
    @level_one = stub("LevelOne", :child    => @level_two,
                                  :policies => :level_one_policies)
    @parent    = stub("Parent",   :child    => @level_one,
                                  :policies => :parent_policies)

    @steps     = (0..1).map { |n| stub("Step-#{n}") }
    @plan      = stub("ExecutionPlan", :steps => @steps)

    @resolver  = Objectify::Config::Resolver.new
    @result    = @resolver.call(@parent, :policies, @plan)
  end

  it "collects the parameters from each of the levels in order" do
    @result.should == [:parent_policies,
                       :level_one_policies,
                       :level_two_policies]
  end

  it "asks each successive level of policy for its step" do
    @parent.should have_received(:child).with(@steps[0])
    @level_one.should have_received(:child).with(@steps[1])
  end
end
