# UnicornMetrics

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'unicorn_metrics'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unicorn_metrics

## Usage

UnicornMetrics::Counter implements a convenient wrapper around an atomic counter.
Register new counters in the application:

    UnicornMetrics.configure do |c|
      # Configure a new counter with the name 'test_counter'
      # Then access this counter UnicornMetrics.test_counter
      # e.g., UnicornMetrics.test_counter.increment
      #
      c.register(:counter, "test_counter")
      #
    end

### Counters

Register a new counter,

    UnicornMetrics.configure do |c|
      c.register(:counter, "test_counter")
    end

Use it in the application

    >> counter = UnicornMetrics.test_counter

    # Getting the count
    >> counter.count
    #=> 0

    # Incrementing
    >> 5.times { counter.increment }
    >> counter.count
    #=> 5

    # Decrementing
    >> 5.times { counter.decrement }
    >> counter.count
    #=> 0

    # Resetting
    >> 5.times { counter.increment }
    >> counter.reset
    >> counter.count
    #=> 0

### HTTP Request and Response Counters

Register a `UnicornMetrics::ResponseCounter` or `UnicornMetrics::RequestCounter` to track
the response status code or request method to a specified path. Not

    # Path is optional
    >> UnicornMetrics.register(:response_counter, "responses.2xx", /[2]\d{2}/)

    # Request counter with a 'path' argument
    >> UnicornMetrics.register(:request_counter, "requests.POST", 'POST', /^\/my_endpoint\/$/)

Default counters can be registered during initial config:

    # Rails.root/config/initializers/unicorn_metrics.rb

    UnicornMetrics.configure do |c|
      c.http_metrics = true #Default false
    end

This will give you these counters for free: "responses.4xx", "responses.5xx", "responses.2xx", "responses.3xx"
"requests.POST", "requests.PUT", "requests.GET", "requests.DELETE"

## Middleware
Included middleware to support exposing metrics to an endpoint. These can then be consumed
by a service that publishes to [Graphite](http://graphite.wikidot.com/).

Important: this middleware builds upon the standard Raindrops middleware.
It is currently set to provide the default Raindrops data as part of the metrics response

Add to the top of the middleware stack in `config.ru`:

    # config.ru

    require 'unicorn_metrics/middleware'
    use UnicornMetrics::Middleware, :path => "/metrics"
    # other middleware...
    run N::Application

Metrics will be published to the defined path (i.e., http://localhost:3000/metrics )

    {
    "my_first_counter": {
        "type": "counter",
        "value": 0
      },
    "responses.2xx": {
        "type": "counter",
        "value": 5
      },
      "responses.3xx": {
        "type": "counter",
        "value": 92
      },
      "responses.4xx": {
        "type": "counter",
        "value": 4
      },
      "responses.5xx": {
        "type": "counter",
        "value": 0
      },
      "requests.GET": {
        "type": "counter",
        "value": 100
      },
      "requests.POST": {
        "type": "counter",
        "value": 1
      },
      "requests.DELETE": {
        "type": "counter",
        "value": 0
      },
      "requests.HEAD": {
        "type": "counter",
        "value": 0
      },
      "requests.PUT": {
        "type": "counter",
        "value": 0
      },
      "raindrops.calling": {
        "type": "counter",
        "value": 0
      },
      "raindrops.calling": {
        "type": "counter",
        "value": 0
      },
      "raindrops.writing": {
        "type": "counter",
        "value": 0
      },
      # This will only work on Linux platforms as specified by the Raindrops::Middleware
      "raindrops.listeners": [
        {
            "127.0.0.1": {
                "active": 10,
                "queued": 5
            }
        }
      ]
    }

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO

- Improve the README
- Implement additional metric types
