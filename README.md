# FaradayPersistentExcon

==============

[![Code Climate](https://codeclimate.com/github/aceofsales/faraday_persistent_excon/badges/gpa.svg)](https://codeclimate.com/github/aceofsales/faraday_persistent_excon)

Adds configurable connection pools per host for persistent http connections

## Status

**Alpha**

All testing for this gem is currently in the form of bench testing.  We're evaulating this gem in our production stack.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'faraday_persistent_excon'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install faraday_persistent_excon

## Usage

In an initializer:

```ruby
Excon.defaults[:tcp_nodelay] = true
Faraday.default_adapter = :persistent_excon
FaradayPersistentExcon.connection_pools = {
  'https://search.example.com' => { size: 5 },
  'http://localhost:9200' => { size: 10, timeout: 2, idle_timeout: 300 }
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aceofsales/faraday_persistent_excon.

