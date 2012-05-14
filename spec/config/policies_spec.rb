require "spec_helper"
require "objectify/config/policies"

describe "Objectify::Config::Policies" do
  before do
    @opts = {:policies => [:a, :b, :c], :skip_policies => :b}
    @policies = Objectify::Config::Policies.new(@opts)
  end

  it "extracts the policies from the options" do
    @policies.policies.should == [:a, :b, :c]
  end

  it "extracts the skip policies from the options" do
    @policies.skip_policies.should == [:b]
  end
end
