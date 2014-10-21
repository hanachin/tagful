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

  describe '.tagful_with' do
    it 'tagged method with specified Module' do
      expect { HoumorPerson.new.say_joke }.to raise_error(HoumorPerson::NotFunny, 'T')
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
  end
end
