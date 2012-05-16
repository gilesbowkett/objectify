require "spec_helper"
require "objectify/executor"

describe "Objectify::Executor" do
  before do
    @instance = stub("Instance")
    @instantiator = stub("Instantiator", :call => @instance)
    @injector = stub("Injector", :call => true)
    @executor = Objectify::Executor.new(@injector, @instantiator)
    @result = @executor.call(:some, :service)
  end

  it "creates an instance with the instantiator" do
    @instantiator.should have_received(:call).with(:some, :service)
  end

  it "calls :call on the instance with the injector" do
    @injector.should have_received(:call).with(@instance, :call)
  end

  it "returns the result of Injector#call" do
    @result.should be_true
  end
end
