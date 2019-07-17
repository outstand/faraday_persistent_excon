# FaradayPersistentExcon

[![Code Climate](https://codeclimate.com/github/aceofsales/faraday_persistent_excon/badges/gpa.svg)](https://codeclimate.com/github/aceofsales/faraday_persistent_excon)

Adds configurable connection pools per host for persistent http connections

## Status

**Beta**

All testing for this gem is currently in the form of bench testing.  We're using this gem in our production stack.

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

- `docker-compose build --pull`
- `docker-compose run --rm faraday_persistent_excon` to run specs

To release a new version:
- Update the version number in `version.rb` and commit the result.
- `docker-compose build --pull`
- `docker-compose run --rm release`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aceofsales/faraday_persistent_excon.

