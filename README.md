# Deferrable

[![Ruby](https://github.com/AkihikoITOH/deferrable/actions/workflows/main.yml/badge.svg)](https://github.com/AkihikoITOH/deferrable/actions/workflows/main.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/0eaab84c2a4eb499dfa1/maintainability)](https://codeclimate.com/github/AkihikoITOH/deferrable/maintainability)

[Go's `defer`](https://tour.golang.org/flowcontrol/12) brought to Ruby.

## Installation

```ruby
gem 'gopher-deferrable'
```

And then execute:

    $ bundle install

## Usage

### Single deferred call
```ruby
require 'deferrable'

class YourClass
  include Deferrable

  def say_hello
    defer { puts 'world' }
    puts 'hello'
  end

  deferrable :say_hello
end

YourClass.new.say_hello

# hello
# world
# => nil
```

### Stacked deferred call
```ruby
require 'deferrable'

class YourClass
  include Deferrable

  def say_hello
    defer { puts 'bye' }
    puts 'hello'
    defer { puts 'world' }
  end

  deferrable :say_hello
end

YourClass.new.say_hello

# hello
# world
# bye
# => nil
```

### On Error
```ruby
require 'deferrable'

class YourClass
  include Deferrable

  def say_hello
    defer { puts 'bye' }
    puts 'hello'
    oops
    defer { puts 'world' }
  end

  def oops
    raise StandardError
  end

  deferrable :say_hello
end

YourClass.new.say_hello

# hello
# bye
# `oops': StandardError (StandardError)
```

### In case of early return
```ruby
require 'deferrable'

class YourClass
  include Deferrable

  def say_hello
    defer { puts 'bye' }
    puts 'hello'
    return 'i gotta go'
    defer { puts 'world' }
  end

  deferrable :say_hello
end

YourClass.new.say_hello

# hello
# bye
# => 'i gotta go'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/AkihikoITOH/deferrable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/AkihikoITOH/deferrable/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Deferrable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/AkihikoITOH/deferrable/blob/master/CODE_OF_CONDUCT.md).
