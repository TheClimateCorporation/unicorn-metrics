require 'test_helper'
require 'unicorn_metrics/middleware'
require 'json'

# Stubbing Raindrops::Linux to support testing listener statistics
# See Raindrops::Middleware and Raindrops::Linux
module Raindrops::Linux
  Stats = Struct.new(:active, :queued)
  def self.tcp_listener_stats(*)  ; [['123', Stats.new(1,5)]] ; end
  def self.unix_listener_stats(*) ; [['456', Stats.new(1,5)]] ; end
end

describe UnicornMetrics::Middleware do
  before do
    @resp_headers = { 'Content-Type' => 'text/plain', 'Content-Length' => '0' }
    @response     = [ 200, @resp_headers, ["test_body"] ]
    @app          = ->(env){ @response }

    # Remove any metrics lingering from previous tests
    UnicornMetrics.metrics.delete_if{true}

    @counter    = UnicornMetrics.register(:counter, "test_counter")
    options     = { metrics: '/metrics', listeners: %w(0.0.0.0:80) }
    @middleware = UnicornMetrics::Middleware.new(@app, options)
  end

  after  { UnicornMetrics.metrics.delete("test_counter")}

  describe "#call" do
    context "when path matches the defined metrics path" do
      before do
        response = @middleware.call({'PATH_INFO' => '/metrics'})
        @hash    =  JSON response[2][0]
      end

      it "returns the metrics response JSON body" do
        @hash.fetch("test_counter").must_equal @counter.as_json.fetch("test_counter")
      end

      it "includes raindrops middleware metrics" do
        @hash.must_include "raindrops.calling"
        @hash.must_include "raindrops.writing"
        @hash.must_include "raindrops.tcp.active"
        @hash.must_include "raindrops.tcp.queued"
      end
    end

    context "when the path does not match the defined metrics path" do
      it "returns the expected response" do
        response = @middleware.call({'PATH_INFO' => '/'})

        # The Raindrops::Middleware wraps the response body in a Proxy
        # Write the response body to a string to match the expectation
        response[2] = [ response[2].inject(""){ |str, v| str << v } ]

        response.must_equal @response
      end
    end
  end

end
