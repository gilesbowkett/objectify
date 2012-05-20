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

  context "appending resolutions" do
    before do
      @locator = stub("ResolverLocator", :add => nil)
      @context = Objectify::Config::Context.new(nil)
      @context.locator = @locator
      @context.append_resolutions :something => String.new
    end

    it "adds them to a locator it has" do
      @locator.should have_received(:add).with(:something, String.new)
    end
  end

  context "the legacy_action" do
    before do
      @action = stub("Action")
      @action_factory = stub("ActionFactory", :new => @action)
      @policies = stub("Policies")
      @policies_factory = stub("PoliciesFactory", :new => @policies)
      @route = stub("Route", :resource => :controller, :action => :action)

      @context = Objectify::Config::Context.new(@policies_factory, @action_factory)
    end

    context "when there's no legacy action config" do
      before do
        @result = @context.legacy_action(@route)
      end

      it "creates a new action with the controller and action name and its policies" do
        @action_factory.should have_received(:new).
                                with(:controller, :action, {}, @policies)
      end
    end

    context "when there is a legacy action config" do
      before do
        @action = stub("Action", :route => @route)
        @context.append_action(@action)
        @result = @context.legacy_action(@route)
      end

      it "returns the existing action" do
        @result.should == @action
      end
    end
  end
end
