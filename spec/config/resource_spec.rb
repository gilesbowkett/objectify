require "spec_helper"
require "objectify/config/resource"

describe "Objectify::Config::Resource" do
  before do
    @policy_conf = stub("PolicyConf")
    @policy_config_factory = stub("PolicyConfFactory",
                                   :new => @policy_conf)

    @action_conf = stub("ActionConf")
    @action_conf_factory = stub("ActionConfFactory",
                                  :new => @action_conf)

    @opts = {:policies      => :asdf,
             :skip_policies => :asdf,
             :create        => {}}
    @resource = Objectify::Config::Resource.new(:pictures,
                                                @opts,
                                                @policy_config_factory,
                                                @action_conf_factory
                                               )
  end

  it "creates a policy config using the factory" do
    @policy_config_factory.should have_received(:new).with(@opts)
    @resource.policies.should == @policy_conf
  end

  it "creates an action config for each action using the factory" do
    Objectify::Config::Resource::ACTIONS.each do |action|
      opts = @opts[action]
      @action_conf_factory.should have_received(:new).with(action, opts)
      @resource.action(action).should == @action_conf
    end
  end
end
