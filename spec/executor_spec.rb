require "spec_helper"
require "objectify/executor"

describe "Objectify::Executor" do
  before do
    @instance = stub("Instance")
    @instantiator = stub("Instantiator", :call => @instance)
    @injector = stub("Injector", :call => true)
    @executor = Objectify::Executor.new(@injector, @instantiator)
  end

  context "with a service" do
    before do
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

  context "with a policy" do
    before do
      @result = @executor.call(:some, :policy)
    end

    it "creates an instance with the instantiator" do
      @instantiator.should have_received(:call).with(:some, :policy)
    end

    it "calls :allowed? on the instance with the injector" do
      @injector.should have_received(:call).with(@instance, :allowed?)
    end

    it "returns the result of Injector#call" do
      @result.should be_true
    end
  end
end
