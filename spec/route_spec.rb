require "spec_helper"
require "objectify/route"

describe "Objectify::Route" do
  context "two routes with the same path" do
    it "have the same #hash value" do
      Objectify::Route.new(:pictures, :index).should ==
        Objectify::Route.new(:pictures, :index)
    end
  end
end
