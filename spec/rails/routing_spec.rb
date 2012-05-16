require "spec_helper"
require "objectify/rails/routing"

describe "Objectify::Rails::Routing::ObjectifyMapper" do
  before do
    @policies       = stub("Policies")
    @objectify      = stub("Objectify",   :append_policy_responders => nil,
                                          :append_defaults          => nil,
                                          :append_action            => nil,
                                          :policies  => @policies)
    @rails_mapper   = stub("RailsMapper", :resources => nil,
                                          :match     => nil)
    @application    = stub("Application", :objectify => @objectify)
    @action         = stub("Action")
    @action_factory = stub("ActionFactory", :new => @action)
    klass           = Objectify::Rails::Routing::ObjectifyMapper
    @mapper         = klass.new(@rails_mapper,
                                @application,
                                @action_factory)
  end

  context "adding a resource" do
    before do
      @mapper.resources(:pictures, :policies => :some_policy,
                                   :create   => {
                                      :policies => :blocked_user,
                                      :service => :picture_creation_v2
                                   })
    end

    it "correctly adds the resource to the rails mapper" do
      opts = { :controller => "objectify/rails/controller" }
      @rails_mapper.should have_received(:resources).
                            with(:pictures, opts)
    end

    it "creates an action for each RESOURCE_ACTIONS" do
      opts = {
        :create => {
          :policies => :blocked_user,
          :service  => :picture_creation_v2
        },
        :policies => :some_policy
      }
      Objectify::Rails::Routing::RESOURCE_ACTIONS.each do |action|
        @action_factory.should have_received(:new).
                                with(:pictures, action, opts, @policies)
      end
    end

    it "appends each of the actions to the objectify object" do
      @objectify.should have_received(:append_action).
                          with(@action).times(7)
    end
  end

  context "setting defaults" do
    before do
      @opts = { :policies => :fuckitttttt }
      @mapper.defaults @opts
    end

    it "hands the defaults to the objectify context" do
      @objectify.should have_received(:append_defaults).with(@opts)
    end
  end

  context "setting policy responders" do
    before do
      @opts = { :authenticated => :unauthenticated_responder }
      @mapper.policy_responders @opts
    end

    it "hands the policy responders to the objectify context" do
      @objectify.should have_received(:append_policy_responders).
                          with(@opts)
    end
  end
end
