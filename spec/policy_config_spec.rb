require "spec_helper"
require "objectify/policy_config"

describe "Objectify::PolicyConfig" do
  before do
    @config_one = Objectify::PolicyConfig.new :policies => [:a, :b],
                                              :skip_policies => :b

    @config_two = Objectify::PolicyConfig.new :policies => [:b, :c, :d],
                                              :skip_policies => :c
  end

  it "can resolve which policies it's supposed to run" do
    @config_one.resolve.should == [:a]
  end

  it "merges policy and skip policy lists in left to right order" do
    @config_one.merge(@config_two).resolve.should == [:a, :b, :d]
  end
end
