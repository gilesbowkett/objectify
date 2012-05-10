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
      @dependency    = stub("Dependency")
      @resolver      = SimpleResolver.new(@dependency)
      @resolver.name = :some_dependency
      @injector      = Objectify::Injector.new([@resolver])
    end

    it "can constructor inject based on method name using a simple resolver" do
      @injector.call(MyInjectedClass, :new).some_dependency.should == @dependency
    end

    it "can method inject based on method name using a simple resolver" do
      object = MyInjectedClass.new(nil)
      @injector.call(object, :call).should == @dependency
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
      @resolver   = stub("Resolver", :name => :some_dependency,
                                     :call => @dependency)
      @injector   = Objectify::Injector.new([ParamsResolver.new])
    end

    it "can inject into resolvers" do
      object = MyInjectedClass.new(nil)
      @injector.call(object, :requires_params).should ==
        {:some => "params"}
    end
  end
end
