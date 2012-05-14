require "spec_helper"
require "objectify/config/action"

describe "Objectify::Config::Action" do
  before do
    @options = {
      :policies => :asdf,
      :skip_policies => :bsdf,
      :service => :something,
      :responder => :pictures_index
    }

    @policy_conf = stub("PolicyConf")
    @policy_config_factory = stub("PolicyConfFactory",
                                   :new => @policy_conf)

    @action = Objectify::Config::Action.new(:index,
                                            @options,
                                            @policy_config_factory)
  end

  it "stores its name" do
    @action.name.should == :index
  end

  it "creates a policy config using the factory" do
    @policy_config_factory.should have_received(:new).with(@options)
    @action.policies.should == @policy_conf
  end

  it "stores service overrides" do
    @action.service.should == :something
  end

  it "stores responder overrides" do
    @action.responder.should == :pictures_index
  end
end
