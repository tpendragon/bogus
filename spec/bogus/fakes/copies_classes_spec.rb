require 'spec_helper'

describe Bogus::CopiesClasses do
  module SampleMethods
    def foo
    end

    def bar(x)
    end

    def baz(x, *y)
    end

    def bam(opts = {})
    end

    def baa(x, &block)
    end
  end

  shared_examples_for 'the copied class' do
    it "copies methods with no arguments" do
      expect(subject).to respond_to(:foo)
      subject.foo
    end

    it "copies methods with explicit arguments" do
      expect(subject).to respond_to(:bar)

      expect(subject.method(:bar).arity).to eq 1

      subject.bar('hello')
    end

    it "copies methods with variable arguments" do
      expect(subject).to respond_to(:baz)

      subject.baz('hello', 'foo', 'bar', 'baz')
    end

    it "copies methods with default arguments" do
      expect(subject).to respond_to(:bam)

      subject.bam
      subject.bam(hello: 'world')
    end

    it "copies methods with block arguments" do
      expect(subject).to respond_to(:baa)

      subject.baa('hello')
      subject.baa('hello') {}
    end
  end

  let(:copies_classes) { Bogus.inject.copies_classes }
  let(:fake_class) { copies_classes.copy(klass) }
  let(:fake) { fake_class.new }

  class FooWithInstanceMethods
    CONST = "the const"
    include SampleMethods
  end

  context "nested constants" do
    let(:klass) { FooWithInstanceMethods }

    it "does not overwrite nested constants" do
      expect(fake_class::CONST).to eq "the const"
    end
  end

  context "instance methods" do
    let(:klass) { FooWithInstanceMethods }
    subject{ fake }

    it_behaves_like 'the copied class'
  end

  context "constructors" do
    let(:klass) {
      Class.new do
        def initialize(hello)
        end

        def foo
        end
      end
    }

    it "adds a no-arg constructor" do
      instance = fake_class.__create__

      expect(instance).to respond_to(:foo)
    end

    it "adds a constructor that allows passing the correct number of arguments" do
      instance = fake_class.new('hello')

      expect(instance).to respond_to(:foo)
    end
  end

  class ClassWithClassMethods
    extend SampleMethods
  end

  context "class methods" do
    let(:klass) { ClassWithClassMethods }
    subject{ fake_class }

    it_behaves_like 'the copied class'
  end

  context "identification" do
    module SomeModule
      class SomeClass
      end
    end

    let(:klass) { SomeModule::SomeClass }

    it "should copy the class name" do
      expect(fake.class.name).to eq 'SomeModule::SomeClass'
    end

    it "should override kind_of?" do
      expect(fake.kind_of?(SomeModule::SomeClass)).to be(true)
    end

    it "should override instance_of?" do
      expect(fake.instance_of?(SomeModule::SomeClass)).to be(true)
    end

    it "should override is_a?" do
      expect(fake.is_a?(SomeModule::SomeClass)).to be(true)
    end

    it "should include class name in the output of fake's class #to_s" do
      expect(fake.class.to_s).to include(klass.name)
    end

    it "should include class name in the output of fake's #to_s" do
      expect(fake.to_s).to include(klass.name)
    end

    it 'should override ===' do
      expect(SomeModule::SomeClass === fake).to be(true)
    end
  end

  shared_examples_for 'spying' do
    def should_record(method, *args)
      expect(subject).to receive(:__record__).with(method, *args)

      subject.send(method, *args)
    end

    it "records method calls with no arguments" do
      should_record(:foo)
    end

    it "records method calls with explicit arguments" do
      should_record(:bar, 'hello')
    end

    it "records method calls with variable arguments" do
      should_record(:baz, 'hello', 'foo', 'bar', 'baz')
    end

    it "records method calls with default arguments" do
      should_record(:bam, hello: 'world')
    end
  end

  context "spying on an instance" do
    let(:klass) { FooWithInstanceMethods }
    subject{ fake }

    include_examples 'spying'
  end

  context "spying on copied class" do
    let(:klass) { ClassWithClassMethods }
    subject { fake_class }

    include_examples 'spying'
  end

  class SomeModel
    def save(*)
      # ignores arguments
    end
  end

  context "copying classes with methods with nameless parameters" do
    let(:klass) { SomeModel }

    it "copies those methods" do
      expect(fake).to respond_to(:save)
    end
  end
end

