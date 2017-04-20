require 'spec_helper'

RSpec.describe FactoryBoy do
  it 'has a version number' do
    expect(FactoryBoy::VERSION).not_to be nil
  end

  let(:klass) do
    Class.new do
      attr_accessor :name
    end
  end

  describe '.define_factory' do
    it 'allows to define a schema' do
      expect { FactoryBoy.define_factory(klass) }.not_to raise_exception
    end

    it 'allows to pass a block with default attributes' do
      expect do
        FactoryBoy.define_factory(klass) do
          name 'foobar'
        end
      end.not_to raise_exception
    end

    it 'accepts a symbol as a first argument' do
      expect do
        FactoryBoy.define_factory(:user) do
          name 'foobar'
        end
      end.not_to raise_exception
    end

    it 'raises an exception when argument is nighter a class nor a symbol' do
      expect do
        FactoryBoy.define_factory('user') do
          name 'foobar'
        end
      end.to raise_exception FactoryBoy::SchemaNotSupported
    end

    it 'allows to define an alias' do
      expect do
        FactoryBoy.define_factory(:admin, class: klass) do
          name 'foobar'
          admin true
        end
      end.not_to raise_exception
    end

    it 'raises an exception if optional class is not a Class' do
      expect do
        FactoryBoy.define_factory(:admin, class: :user) do
          name 'foobar'
          admin true
        end
      end.to raise_exception FactoryBoy::InvalidOptionalClass
    end
  end

  describe '.build' do
    context 'schema is correctly defined for explicit class' do
      before do
        FactoryBoy.define_factory(klass)
      end

      it 'returns an instance of given class' do
        expect(FactoryBoy.build(klass)).to be_instance_of klass
      end

      it 'allows to pass optional attributes' do
        instance = FactoryBoy.build(klass, name: 'foobar')
        expect(instance.name).to eq 'foobar'
      end

      it 'raises an exception when you give a symbol instead of class' do
        expect { FactoryBoy.build(:user) }.to raise_exception FactoryBoy::SchemaNotDefined
      end
    end

    context 'schema is defined with the block' do
      before do
        FactoryBoy.define_factory(klass) do
          name 'foobar'
        end
      end

      it 'returns an instance of given class' do
        expect(FactoryBoy.build(klass)).to be_instance_of klass
      end

      it 'reterun an instance of given class with default attributes' do
        instance = FactoryBoy.build(klass)
        expect(instance.name).to eq 'foobar'
      end

      it 'allows to pass optional attributes' do
        instance = FactoryBoy.build(klass, name: 'baz')
        expect(instance.name).to eq 'baz'
      end
    end

    context 'schema is defined with the symbol' do
      before do
        User = klass
        FactoryBoy.define_factory(:user) do
          name 'foobar'
        end
      end

      after do
        Object.send(:remove_const, :User)
      end

      it 'returns an instance of given class' do
        expect(FactoryBoy.build(:user)).to be_instance_of klass
      end

      it 'returns an instance of given class with default attributes' do
        instance = FactoryBoy.build(:user)
        expect(instance.name).to eq 'foobar'
      end

      it 'raises an exception when you give a class instead of symbol' do
        expect { FactoryBoy.build(klass) }.to raise_exception FactoryBoy::SchemaNotDefined
      end
    end

    context 'schema is defined with the alias' do
      before do
        User = klass
        FactoryBoy.define_factory(:admin, class: klass) do
          name 'foobar'
        end
      end

      after do
        Object.send(:remove_const, :User)
      end

      it 'returns an instance of given class' do
        expect(FactoryBoy.build(:admin)).to be_instance_of klass
      end

      it 'returns an instance of given class with default attributes' do
        instance = FactoryBoy.build(:admin)
        expect(instance.name).to eq 'foobar'
      end

      it 'raises an exception when you give a class instead of symbol' do
        expect { FactoryBoy.build(klass) }.to raise_exception FactoryBoy::SchemaNotDefined
      end
    end

    context 'schema is undefined' do
      it 'raises an exception for an explicit class' do
        expect do
          FactoryBoy.build(klass)
        end.to raise_exception FactoryBoy::SchemaNotDefined
      end

      it 'raises an exception for a symbol' do
        expect do
          FactoryBoy.build(:foo)
        end.to raise_exception FactoryBoy::SchemaNotDefined
      end
    end

    context 'attributes are invalid' do
      before do
        FactoryBoy.define_factory(klass)
      end

      it 'raises an exception' do
        expect do
          FactoryBoy.build(klass, invalid_attr: 'foobar')
        end.to raise_exception FactoryBoy::InvalidAttributes, 'invalid_attr attribute is wrong'
      end
    end
  end
end
