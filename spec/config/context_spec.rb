require "spec_helper"
require "objectify/config/context"

describe "Objectify::Config::Context" do
  before do
    @policies = stub("Policies")
    @policies_factory = stub("PoliciesFactory", :new => @policies)

    @resource = stub("Resource")
    @resource_factory = stub("ResourceFactory", :new => @resource)

    @context = Objectify::Config::Context.new(@resource_factory,
                                              @policies_factory)
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

  context "appending resources" do
    before do
      @opts = {:policies => [:x,:y,:z]}
      @context.append_resources(:pictures, @opts)
    end

    it "creates and stores a resource using the factory" do
      @resource_factory.should have_received(:new).with(:pictures, @opts)
      @context.resources[:pictures].should == @resource
    end

    it "returns resource children by name" do
      step = stub("Step", :type => :resource, :name => :pictures)
      @context.child(step).should == @resource
    end

    it "raises on missing steps" do
      step = stub("Step", :type => :resource, :name => :missing)
      lambda { @context.child(step) }.should raise_error
    end
  end
end
