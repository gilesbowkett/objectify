require "spec_helper"
require "objectify/policy_chain_executor"

describe "Objectify::PolicyChainExecutor" do
  before do
    @policies       = [:x, :y, :z]
    @action         = stub("Action", :policies => @policies)
    @executor       = stub("Executor", :call => true)
    @responder      = :an_responder
    @context        = stub("Context", :policy_responder => @responder)

    @chain_executor = Objectify::PolicyChainExecutor.new(@executor, @context)
  end

  context "when all the policies execute successfully" do
    before do
      @result = @chain_executor.call(@action)
    end

    it "calls each of the policies with the executor" do
      @policies.each do |policy|
        @executor.should have_received(:call).with(policy, :policy)
      end
    end

    it "doesn't call any responders" do
      @executor.should_not have_received(:call).with(anything, :responder)
    end

    it "returns true" do
      @result.should be_true
    end
  end

  context "when one of the policies returns false" do
    before do
      @executor.stubs(:call).with(:y, :policy).returns(false)
      @result = @chain_executor.call(@action)
    end

    it "calls each of the policies with the executor" do
      @policies[0..1].each do |policy|
        @executor.should have_received(:call).with(policy, :policy)
      end
    end

    it "doesn't call any the policies after the one that failed" do
      @executor.should_not have_received(:call).with(:z, :policy)
    end

    it "fetches and calls the policy responder for that policy" do
      @context.should have_received(:policy_responder).with(:y)
      @executor.should have_received(:call).with(:an_responder, :responder)
    end

    it "returns false" do
      @result.should be_false
    end
  end
end
