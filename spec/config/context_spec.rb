require "spec_helper"
require "objectify/config/context"

describe "Objectify::Config::Context" do
  before do
    @policies = stub("Policies")
    @policies_factory = stub("PoliciesFactory", :new => @policies)

    @context = Objectify::Config::Context.new(@policies_factory)
  end

  context "appending policy responders" do
    before do
      @context.append_policy_responders :authenticated => :unauthenticated
      @context.append_policy_responders :blocked_profile => :unauthorized
    end
    
    it "is cumulative" do
      responders = {:authenticated => :unauthenticated,
                    :blocked_profile => :unauthorized}
      @context.policy_responders.should == responders
    end

    it "retrieves responders by policy name" do
      @context.policy_responder(:authenticated).should == :unauthenticated
    end

    it "raises an error when a responder is missing" do
      f = lambda { @context.policy_responder(:missing) }
      f.should raise_error
    end
  end

  context "setting defaults" do
    before do
      @opts = {:policies => [:a, :b], :skip_policies => :c}
      @context.append_defaults @opts
    end
    
    it "uses the policies factory to create and store policies" do
      @policies_factory.should have_received(:new).with(@opts)
      @context.policies.should == @policies
    end
  end

  context "appending actions" do
    before do
      @route = stub("Route")
      @action = stub("Action", :route => @route)
      @context.append_action(@action)
    end

    it "retrieves actions by route" do
      @context.action(@route).should == @action
    end

    it "raises an error when no action for a route exists" do
      lambda { @context.action(stub()) }.should raise_error
    end
  end
  
  context "when there are no default policies" do
    before do
      @context = Objectify::Config::Context.new
    end

    it "returns an empty policies objectify" do
      @context.policies.policies.should be_empty
      @context.policies.skip_policies.should be_empty
    end
  end
end
