require "spec_helper"

class User
  attr_accessor :name
end

RSpec.describe FactoryBoy do
  it "has a version number" do
    expect(FactoryBoy::VERSION).not_to be nil
  end

  describe ".define_factory" do
    it "allows to define a schema" do
      expect { FactoryBoy.define_factory(User) }.not_to raise_exception
    end
  end

  describe ".build" do
    context "schema is correctly defined" do
      before do
        FactoryBoy.define_factory(User)
      end

      it "returns an instance of User class" do
        expect(FactoryBoy.build(User)).to be_instance_of User
      end

      it "allows to pass optional attributes" do
        instance = FactoryBoy.build(User, name: "foobar")
        expect(instance.name).to eq "foobar"
      end
    end

    context "schema is missing" do
      it "raises an exception" do
        expect { FactoryBoy.build(User) }.to raise_exception FactoryBoy::SchemaNotDefined
      end
    end
  end
end
