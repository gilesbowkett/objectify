require "spec_helper"
require "objectify/injector"

describe "Objectify::Injector" do
  class MyInjectedClass
    attr_reader :some_dependency

    def initialize(some_dependency)
      @some_dependency = some_dependency
    end

    def call(some_dependency)
      some_dependency
    end

    def requires_params(params)
      params
    end

    def optional_arg(asdf=true)
    end
  end

  # gotta use a fake resolver here because mocha sucks balls lolruby
  class SimpleResolver
    attr_accessor :name

    def initialize(something)
      @something = something
    end

    def call
      @something
    end
  end

  describe "the simple case" do
    before do
      @dependency       = stub("Dependency")
      @resolver         = SimpleResolver.new(@dependency)
      @resolver_locator = stub("ResolverLocator", :call => @resolver)
      @injector         = Objectify::Injector.new(@resolver_locator)
    end

    it "can constructor inject based on method name using a simple resolver" do
      @injector.call(MyInjectedClass, :new).some_dependency.should == @dependency
    end

    it "can method inject based on method name using a simple resolver" do
      object = MyInjectedClass.new(nil)
      @injector.call(object, :call).should == @dependency
    end

    it "calls the resolver_locator to get the resolver" do
      @injector.call(MyInjectedClass, :new)
      @resolver_locator.should have_received(:call).with(:some_dependency)
    end

    it "supports optional arguments" do
      obj = MyInjectedClass.new("Asdf")
      lambda { @injector.call(obj, :optional_arg) }.should_not raise_error
    end
  end

  class ParamsResolver
    def name
      :params
    end

    def call
      {:some => "params"}
    end
  end

  context "recursive injection in to resolvers" do
    before do
      @resolver         = ParamsResolver.new
      @resolver_locator = stub("ResolverLocator", :call => @resolver)
      @injector         = Objectify::Injector.new(@resolver_locator)
    end

    it "can inject into resolvers" do
      object = MyInjectedClass.new(nil)
      @injector.call(object, :requires_params).should ==
        {:some => "params"}
    end
  end
end
