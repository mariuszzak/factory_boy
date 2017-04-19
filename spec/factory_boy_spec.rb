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

    it "allows to pass a block with default attributes" do
      expect do
        FactoryBoy.define_factory(User) do
          name "foobar"
        end
      end.not_to raise_exception
    end

    it "accepts a symbol as a first argument" do
      expect do
        FactoryBoy.define_factory(:user) do
          name "foobar"
        end
      end.not_to raise_exception
    end

    it "raises an exception when argument is nighter a class nor a symbol" do
      expect do
        FactoryBoy.define_factory("user") do
          name "foobar"
        end
      end.to raise_exception FactoryBoy::SchemaNotSupported
    end

    it "allows to define an alias" do
      expect do
        FactoryBoy.define_factory(:admin, class: User) do
          name "foobar"
          admin true
        end
      end.not_to raise_exception
    end

    it "raises an exception if optional class is not a Class" do
      expect do
        FactoryBoy.define_factory(:admin, class: :user) do
          name "foobar"
          admin true
        end
      end.to raise_exception FactoryBoy::InvalidOptionalClass
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

    context "schema is defined with the block" do
      before do
        FactoryBoy.define_factory(User) do
          name "foobar"
        end
      end

      it "returns an instance of User class" do
        expect(FactoryBoy.build(User)).to be_instance_of User
      end

      it "reterun an instance of User class with default attributes" do
        instance = FactoryBoy.build(User)
        expect(instance.name).to eq "foobar"
      end

      it "allows to pass optional attributes" do
        instance = FactoryBoy.build(User, name: "baz")
        expect(instance.name).to eq "baz"
      end
    end

    context "schema is defined with the symbol" do
      before do
        FactoryBoy.define_factory(:user) do
          name "foobar"
        end
      end

      it "returns an instance of User class" do
        expect(FactoryBoy.build(:user)).to be_instance_of User
      end

      it "reterun an instance of User class with default attributes" do
        instance = FactoryBoy.build(:user)
        expect(instance.name).to eq "foobar"
      end
    end

    context "schema is missing" do
      it "raises an exception" do
        expect do
          FactoryBoy.build(User)
        end.to raise_exception FactoryBoy::SchemaNotDefined
      end
    end

    context "attributes are invalid" do
      before do
        FactoryBoy.define_factory(User)
      end

      it "raises an exception" do
        expect do
          FactoryBoy.build(User, invalid_attr: "foobar")
        end.to raise_exception FactoryBoy::InvalidAttributes, "invalid_attr attribute is wrong"
      end
    end
  end
end
