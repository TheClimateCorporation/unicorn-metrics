require 'raindrops'
require 'unicorn_metrics/registry'
require 'unicorn_metrics/version'
require 'unicorn_metrics/counter'
require 'unicorn_metrics/default_http_counters'
require 'unicorn_metrics/status_counter'
require 'unicorn_metrics/method_counter'
require 'forwardable'

module UnicornMetrics
  class << self

    # Delegating to the Registry for configuration options
    def registry
      UnicornMetrics::Registry
    end

    # Make this class 'configurable'
    def configure
      yield self
    end

    # Enable/disable metrics gathering for endpoints
    def http_metrics=(boolean=false)
      return if @_assigned

      if @http_metrics = boolean
        registry.extend(UnicornMetrics::DefaultHttpCounters)
        registry.register_default_http_counters
      end
      @_assigned = true
    end

    def http_metrics? ; @http_metrics ; end

    private
    # http://robots.thoughtbot.com/post/28335346416/always-define-respond-to-missing-when-overriding
    def respond_to_missing?(method_name, include_private=false)
      registry.respond_to?(method_name, include_private)
    end

    def method_missing(method_name, *args, &block)
      return super unless registry.respond_to?(method_name)
      registry.send(method_name, *args, &block)
    end
  end
end
