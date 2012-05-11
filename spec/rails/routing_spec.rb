require "spec_helper"
require "objectify/rails/routing"

describe "Objectify::Rails::Routing::ObjectifyMapper" do
  before do
    @objectify    = stub("Objectify",   :append_policy_responders => nil,
                                        :append_defaults          => nil,
                                        :append_routes            => nil)
    @rails_mapper = stub("RailsMapper", :resources => nil,
                                        :match     => nil)
    @application  = stub("Application", :objectify => @objectify)
    klass         = Objectify::Rails::Routing::ObjectifyMapper
    @mapper       = klass.new(@rails_mapper, @application)
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
      opts = { :controller => :objectify }
      @rails_mapper.should have_received(:resources).
                            with(:pictures, opts)
    end

    it "hands the objectify routing info to objectify" do
      opts = {
        :create => {
          :policies => :blocked_user,
          :service  => :picture_creation_v2
        },
        :policies => :some_policy
      }
      @objectify.should have_received(:append_routes).with(:pictures, opts)
    end
  end

  context "setting defaults" do
    before do
      @opts = { :policies => :fuckitttttt }
      @mapper.defaults @opts
    end

    it "handls the defaults to the objectify context" do
      @objectify.should have_received(:append_defaults).with(@opts)
    end
  end
end
