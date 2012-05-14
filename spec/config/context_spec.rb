require "spec_helper"
require "objectify/config/context"

describe "Objectify::Config::Context" do
  before do
    @resource = stub("Resource")
    @resource_factory = stub("ResourceFactory", :new => @resource)

    @context = Objectify::Config::Context.new(@resource_factory)
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

  context "appending defaults" do
    before do
      @context.append_defaults :policies => [:a, :b]
      @context.append_defaults :policies => [:c, :d]
    end
    
    it "is cumulative" do
      defaults = {
        :policies => [:a, :b, :c, :d]
      }
      @context.defaults.should == defaults
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
  end
end
