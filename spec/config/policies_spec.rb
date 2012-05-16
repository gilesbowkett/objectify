require "spec_helper"
require "objectify/config/policies"

describe "Objectify::Config::Policies" do
  before do
    @opts = {:policies => [:a, :b, :c], :skip_policies => :b}
    @policies = Objectify::Config::Policies.new(@opts)
    @policies2 = Objectify::Config::Policies.new(:skip_policies => :c)
  end

  it "extracts the policies from the options" do
    @policies.policies.should == [:a, :b, :c]
  end

  it "extracts the skip policies from the options" do
    @policies.skip_policies.should == [:b]
  end

  it "can merge with hashes of policy configs" do
    @policies.merge({:skip_policies => :c},
                    {:policies => :b}).policies.should == [:a, :b]
  end
end
