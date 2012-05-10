require "spec_helper"
require "objectify/instantiator"

describe "Objectify::Instantiator" do
  class MyService
  end

  before do
    @service      = MyService.new
    @injector     = stub("Injector", :call => @service)
    @instantiator = Objectify::Instantiator.new(@injector)
    @result       = @instantiator.call(:my, :service)
  end

  it "returns the result of injector#call" do
    @result.should == @service
  end

  it "calls the injector with the generated constant" do
    @injector.should have_received(:call).with(MyService, :new)
  end
end
