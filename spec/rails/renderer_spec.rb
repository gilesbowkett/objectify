require "spec_helper"
require "objectify/rails/renderer"

describe "Objectify::Rails::Renderer" do
  before do
    @controller = stub("Controller", :render => nil)
    @renderer = Objectify::Rails::Renderer.new(@controller)
  end

  it "delegates template rendering" do
    @renderer.template("something.html.erb", :some => :option)
    @controller.should have_received(:render).with(:template => "something.html.erb",
                                                   :some     => :option)
  end

  it "delegates action rendering" do
    @renderer.action("something.html.erb", :some => :option)
    @controller.should have_received(:render).with(:action => "something.html.erb",
                                                   :some   => :option)
  end

  it "delegates partial rendering" do
    @renderer.partial("something.html.erb", :some => :option)
    @controller.should have_received(:render).with(:partial => "something.html.erb",
                                                   :some    => :option)
  end

  it "delegates rendering nothing" do
    @renderer.nothing(:some => :option)
    @controller.should have_received(:render).with(:nothing => true,
                                                   :some => :option)
  end

  it "exposes the full render method" do
    @renderer.render(:json => "asdf")
    @controller.should have_received(:render).with(:json => "asdf")
  end

  it "delegates the respond_to method" do
    @responder = stub("Responder")
    @responder.stubs(:html).yields
    @controller.stubs(:respond_to).yields(@responder)

    @renderer.respond_to do |format|
      format.html { }
    end

    @responder.should have_received(:html)
  end
end
