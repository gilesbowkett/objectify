require "spec_helper"
require "objectify/config/context"

describe "Objectify::Config::Context" do
  before do
    @context = Objectify::Config::Context.new
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

  context "appending routes" do
    before do
      @opts = {:policies => [:x,:y,:z]}
      @context.append_routes(:pictures, @opts)
    end

    it "uses the resource name as the hash key & the opts as the value" do
      @context.routes[:pictures].should == @opts
    end
  end
end
