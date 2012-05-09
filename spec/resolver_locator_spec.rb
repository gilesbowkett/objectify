require "spec_helper"
require "objectify/resolver_locator"

describe "Objectify::ArrayResolverLocator" do
  before do
    @locator_a = stub("Resolver", :name => :a)
    @locator_b = stub("Resolver", :name => :b)
    @resolvers = [@locator_a, @locator_b]
    @resolver_locator = Objectify::ArrayResolverLocator.new(@resolvers)
  end

  it "returns locators by name" do
    @resolver_locator.call(:a).should == @locator_a
    @resolver_locator.call(:b).should == @locator_b
  end
end

describe "Objectify::MultiResolverLocator" do
  before do
    @locator_a        = stub("LocatorA", :call => nil)
    @locator_a.stubs(:call).with(:a).returns(:resolver_a)
    @locator_b        = stub("LocatorB", :call => nil)
    @locator_b.stubs(:call).with(:b).returns(:resolver_b)

    @locators         = [@locator_a, @locator_b]
    @resolver_locator = Objectify::MultiResolverLocator.new(@locators)
  end

  it "searches through its locators for a resolver" do
    @resolver_locator.call(:a).should == :resolver_a
    @resolver_locator.call(:b).should == :resolver_b
  end
  
  it "raises ArgumentError when a resolver can't be found" do
    not_found = lambda { @resolver_locator.call(:asdf) }
    not_found.should raise_error(ArgumentError)
  end
end
