require "spec_helper"
require "objectify/rails/routing"

describe "Objectify::Rails::Routing::ObjectifyMapper" do
  before do
    @policies       = stub("Policies")
    @objectify      = stub("Objectify",   :append_policy_responders => nil,
                                          :append_defaults          => nil,
                                          :append_action            => nil,
                                          :policies  => @policies,
                                          :append_resolutions       => nil,
                                          :objectify_controller => "some_controller")
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
      opts = { :controller => @objectify.objectify_controller,
               :defaults   => {:objectify => {:resource => :pictures}}}
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

  context "adding a resource with its own defaults" do
    before do
      @mapper.resources(:pictures, :policies => :some_policy,
                                   :create   => {
                                      :policies => :blocked_user,
                                      :service => :picture_creation_v2
                                   },
                                   :defaults => {:some => :bullshit})
    end

    it "correctly adds the resource to the rails mapper" do
      opts = { :controller => @objectify.objectify_controller,
               :defaults   => {:objectify => {:resource => :pictures},
                               :some      => :bullshit}}
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

  context "adding a resource with an alternative objectify_controller" do
    before do
      @objectify.stubs(:objectify_controller).returns("asdfbsdf")
      @mapper.resources(:pictures, :policies => :some_policy,
                                   :create   => {
                                      :policies => :blocked_user,
                                      :service => :picture_creation_v2
                                   },
                                   :defaults => {:some => :bullshit})
    end

    it "correctly adds the resource to the rails mapper" do
      opts = { :controller => @objectify.objectify_controller,
               :defaults   => {:objectify => {:resource => :pictures},
                               :some      => :bullshit}}
      @rails_mapper.should have_received(:resources).
                            with(:pictures, opts)
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

  context "adding resolutions" do
    before do
      @opts = { :authenticated => :unauthenticated_responder }
      @mapper.resolutions @opts
    end

    it "hands them to the context" do
      @objectify.should have_received(:append_resolutions).
                          with(@opts)
    end
  end

  context "adding a legacy action" do
    before do
      @opts = {:policies => "asdf"}
      @mapper.legacy_action :controller, [:action1, :action2], @opts
    end

    it "creates actions for each of the specified actions" do
      @action_factory.should have_received(:new).
                              with(:controller, :action1, @opts, @policies)

      @action_factory.should have_received(:new).
                              with(:controller, :action2, @opts, @policies)
    end

    it "passes the actions to the objectify objects" do
      @objectify.should have_received(:append_action).with(@action).twice
    end
  end
end
