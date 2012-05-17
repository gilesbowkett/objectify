require "spec_helper"
require "objectify/resolver"

describe "Objectify::NamedValueResolver" do
  before do
    @named_value_resolver = Objectify::NamedValueResolver.new(:name, :value)
  end

  it "returns the supplied name" do
    @named_value_resolver.name.should == :name
  end

  it "returns the supplied value" do
    @named_value_resolver.call.should == :value
  end
end

class MyResolver; end

describe "Objectify::NameTranslationResolver" do
  before do
    @resolver = Objectify::NameTranslationResolver.new(:a, :my_resolver)
  end

  it "instantiates resolvers" do
    @resolver.call.should be_instance_of(MyResolver)
  end
end
