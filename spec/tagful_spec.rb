require 'spec_helper'

RSpec.describe Tagful do
  class Person
    module Error; end

    include Tagful

    def yo
      raise 'yo'
    end

    def hi
      raise 'hi'
    end
    tagful :hi

    def hello
      Hello.new
    end
    tagful :hello

    private

    def heart
      # you can't touch my heart
    end
    tagful :heart
  end

  class HoumorPerson < Person
    module NotFunny; end

    def say_joke
      puts 'coffee or tea?'
      raise 'T'
    end
    tagful :say_joke, NotFunny
  end

  class Hello
    class Mad < StandardError; end

    def initialize
      raise Mad, "ugh!"
    end
  end

  class Robot
    include Tagful

    module Broken; end
    module NoBattery; end

    tagful_with Broken

    def to_evil
      raise ':('
    end
    tagful :to_evil

    def walk
      raise
    end
    tagful :walk, NoBattery
  end

  class Pizza
    include Tagful

    class Dirty < StandardError; end

    class Factory
      def self.exception(message = nil)
        Dirty.new("something wrong in pizza factory: #{message}")
      end
    end

    class NotFound < ArgumentError
      def self.exception(message = nil)
        super("not found: #{message}")
      end
    end

    tagful_with Pizza::Factory

    def initialize(contamination = nil)
      if contamination
        raise contamination.to_s
      end
    end
    tagful :initialize

    def take_cheese!
      raise 'cheese'
    end
    tagful :take_cheese!, NotFound
  end

  module Bar
    def bar
      'top bar'
    end
  end

  class Foo
    module Bar
      def self.to_s
        'Bug!'
      end

      def bar
        'Foo::Bar'
      end
    end

    include Tagful

    tagful_with ::Bar

    def bug
      raise 'bug'
    end
    tagful :bug
  end

  class Buzz < StandardError
    def buzz
      'top buzz'
    end
  end

  class Fizz
    class Buzz < StandardError
      def buzz
        'Buzz::buzz'
      end
    end

    include Tagful

    tagful_with ::Buzz

    def fizz
      raise 'buzz'
    end
    tagful :fizz
  end

  class Anonymous
    include Tagful

    def anonymous_module
      raise 'anonymouse module'
    end
    tagful :anonymous_module, Module.new {
      def anonymous
        'anonymous module'
      end
    }

    def anonymous_class
      raise 'anonymouse class'
    end
    tagful :anonymous_class, Class.new(StandardError) {
      def anonymous
        'anonymous class'
      end
    }
  end

  describe '.tagful_with' do
    it 'tagged method with specified Module' do
      expect { Robot.new.to_evil }.to raise_error(Robot::Broken, ':(')
    end

    it 'respect tagful arguments' do
      expect { Robot.new.walk }.to raise_error(Robot::NoBattery) do |error|
        expect(error).to_not be_an(Robot::Broken)
      end
    end

    context 'tagged with class' do
      it 'raise error by class.exception' do
        expect { Pizza.new('bug') }.to raise_error(Pizza::Dirty, 'something wrong in pizza factory: bug')
      end
    end

    context 'tagged with top level module, but the same name module exists in class' do
      it 'tagged by top level module' do
        expect { Foo.new.bug }.to raise_error do |error|
          expect(error).to be_an(::Bar)
          expect(error.bar).to eq 'top bar'
        end
      end
    end

    context 'tagged with top level class, but the same name class exists in class' do
      it 'tagged by top level class' do
        expect { Fizz.new.fizz }.to raise_error do |error|
          expect(error).to be_an(::Buzz)
          expect(error.buzz).to eq 'top buzz'
        end
      end
    end
  end

  describe '.tagful' do
    context 'not tagged method' do
      it 'raise not tagged error' do
        expect { Person.new.yo }.to raise_error do |error|
          expect(error).not_to be_a(Person::Error)
          expect(error.message).to eq 'yo'
        end
      end
    end

    context 'tagged method' do
      it 'raise tagged error' do
        expect { Person.new.hi }.to raise_error(Person::Error, 'hi')
      end

      it 'respect method visibility' do
        expect { Person.new.heart }.to raise_error
      end
    end

    context 'raise error from inside of tagged method' do
      it 'raise tagged error' do
        expect { Person.new.hello }.to raise_error do |error|
          expect(error).to be_an(Hello::Mad).and be_an(Person::Error)
          expect(error.message).to eq 'ugh!'
        end
      end
    end

    context 'tagged with class' do
      it 'raise tagged error class' do
        expect { Pizza.new.take_cheese! }.to raise_error(Pizza::NotFound, 'not found: cheese')
      end
    end

    context 'tagged with anonymouse class' do
      it 'raise tagged error class' do
        expect { Anonymous.new.anonymous_class }.to raise_error do |error|
          expect(error.anonymous).to eq 'anonymous class'
        end
      end
    end

    context 'tagged with anonymouse module' do
      it 'raise tagged error module' do
        expect { Anonymous.new.anonymous_module }.to raise_error do |error|
          expect(error.anonymous).to eq 'anonymous module'
        end
      end
    end
  end
end
