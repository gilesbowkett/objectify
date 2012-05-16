require "spec_helper"
require "objectify/config/action"

describe "Objectify::Config::Action" do
  before do
    @index_options = {
      :service => :something,
      :responder => :pictures_index
    }

    @options = {
      :policies => :asdf,
      :skip_policies => :bsdf,
      :index => @index_options
    }

    @merged_policies  = stub("MergedPolicies")
    @default_policies = stub("PolicyConf", :merge => @merged_policies)

    @route            = stub("Route")
    @route_factory    = stub("RouteFactory", :new => @route)

    @action = Objectify::Config::Action.new(:pictures,
                                            :index,
                                            @options,
                                            @default_policies,
                                            @route_factory)
  end

  it "creates and stores a route from the route factory" do
    @route_factory.should have_received(:new).with(:pictures, :index)
    @action.route.should == @route
  end

  it "stores its resource_name" do
    @action.resource_name.should == :pictures
  end

  it "stores its name" do
    @action.name.should == :index
  end

  it "merges and stores the policy configurations" do
    @default_policies.should have_received(:merge).with(@options,
                                                        @index_options)
    @action.policies.should == @merged_policies
  end

  it "stores service overrides" do
    @action.service.should == :something
  end

  it "stores responder overrides" do
    @action.responder.should == :pictures_index
  end
end
