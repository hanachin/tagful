# Tagful

Tagging your exception.

based on: [Exceptional Ruby: Master the art of handling failure in Ruby](http://exceptionalruby.com/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tagful'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tagful

## Usage

Tagging your exception with `tagful`

    class Person
      # Ruby 2.1 or later
      tagful\
      def hello
        raise 'hello'
      end

      # Ruby 2.0
      def hello
        raise 'hello'
      end
      tagful :hello
    end

    begin
      Person.new.hello
    rescue Person::Error => e
      puts e.message
    end
    # => hello

## TODO
You can specify your error module by `tagful_with`:

    class Robot
      module Broken; end

      tagful_with Broken

      tagful\
      def initialize
        raise ':('
      end
    end

    begin
      Robot.new
    rescue Robot::Broken => e
      puts e.message
    end
    # => :(

or pass your error module to `tagful`:

    class Person
      module NoManner; end

      def eat
        raise 'burps'
      end
      tagful :eat, NoManner
    end

    begin
      Person.eat
    rescue NoManner => e
      puts e.message
    end
    # => burps

You can use `Class` instead of `Module`:

    class Pizza
      class NotFound < ArgumentError
        def exception(message = nil)
          super("not found: #{message}")
        end
      end

      def take_cheese!
        raise 'cheese'
      end
      tagful_with :take_cheese!, NotFound
    end

    begin
      Pizza.new.take_cheese!
    rescue Pizza::NotFound => e
      puts e.message
    end
    # => not found: cheese

## Contributing

1. Fork it ( https://github.com/hanachin/tagful/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
