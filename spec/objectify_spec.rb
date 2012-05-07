require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Objectify::Injector" do
  class MyInjectedClass
    attr_reader :some_dependency

    def initialize(some_dependency)
      @some_dependency = some_dependency
    end
  end

  before do
    @dependency = stub("Dependency")
    @resolver   = stub("Resolver", :name => :some_dependency,
                                   :call => @dependency)
    @injector   = Objectify::Injector.new([@resolver])
  end

  it "can inject based on method name using a simple resolver" do
    @injector.call(MyInjectedClass, :new).some_dependency.should == @dependency
  end
end
