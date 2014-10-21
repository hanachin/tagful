require 'spec_helper'

RSpec.describe Tagful do
  class Person
    module Error; end

    include Tagful

    def yo
      raise 'yo'
    end

    tagful\
    def hi
      raise 'hi'
    end

    tagful\
    def hello
      Hello.new
    end

    private

    tagful\
    def heart
      # you can't touch my heart
    end
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

    tagful\
    def to_evil
      raise ':('
    end

    def walk
      raise
    end
    tagful :walk, NoBattery
  end

  class Pizza
    include Tagful

    class NotFound < ArgumentError
      def self.exception(message = nil)
        super("not found: #{message}")
      end
    end

    def take_cheese!
      raise 'cheese'
    end
    tagful :take_cheese!, NotFound
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
  end
end
