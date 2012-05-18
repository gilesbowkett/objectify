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

  it "accepts a temporary, contextual locator which takes priority" do
    @temp_locator = stub("TempLocator", :call => :temp_resolver)
    @resolver_locator.context(@temp_locator)
    @resolver_locator.call(:a).should == :temp_resolver
    @resolver_locator.clear_context
    @resolver_locator.call(:a).should == :resolver_a
  end
end

describe "Objectify::NamedValueResolverLocator" do
  before do
    @resolver = stub("Resolver")
    @factory = stub("ResolverFactory", :new => @resolver)
    @locator = Objectify::NamedValueResolverLocator.new(@factory)
  end

  it "#call returns the per-name resolver" do
    @locator.add(:name, :value)
    @locator.call(:name).should == @resolver
  end

  it "#add creates a resolver for the supplied key/value pair" do
    @locator.add(:name, :value)
    @factory.should have_received(:new).with(:name, :value)
  end
end

class MyResolver; end
module Something; class MyResolver; end; end

describe "Objectify::ConstResolverLocator" do
  context "in the global namespace" do
    before do
      @locator = Objectify::ConstResolverLocator.new
    end

    it "finds resolvers by const name" do
      @locator.call(:my).should be_instance_of(MyResolver)
    end

    it "returns nil if the const is missing" do
      @locator.call(:missing).should be_nil
    end

    it "keeps a cache of instantiated resolvers" do
      obj1 = @locator.call(:my)
      obj2 = @locator.call(:my)
      obj1.object_id.should == obj2.object_id
    end
  end

  context "in an arbitrary namespace" do
    before do
      @locator = Objectify::ConstResolverLocator.new("something")
    end

    it "finds resolvers by const name" do
      @locator.call(:my).should be_instance_of(Something::MyResolver)
    end

    it "returns nil if the const is missing" do
      @locator.call(:missing).should be_nil
    end

    it "keeps a cache of instantiated resolvers" do
      obj1 = @locator.call(:my)
      obj2 = @locator.call(:my)
      obj1.object_id.should == obj2.object_id
    end
  end
end
