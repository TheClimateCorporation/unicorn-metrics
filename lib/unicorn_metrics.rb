module UnicornMetrics
  class << self

    # Returns the UnicornMetrics::Registry object
    #
    # @return [UnicornMetrics::Registry]
    def registry
      UnicornMetrics::Registry
    end

    # Make this class 'configurable'
    #
    # @yieldparam self [UnicornMetrics]
    def configure
      yield self
    end

    # Enable/disable HTTP metrics. Includes defaults
    #
    # @param boolean [Boolean] to enable or disable default HTTP metrics
    def http_metrics=(boolean=false)
      return if @_assigned

      if @http_metrics = boolean
        registry.extend(UnicornMetrics::DefaultHttpMetrics)
        registry.register_default_http_counters
        registry.register_default_http_timers
      end
      @_assigned = true
    end

    # Used by the middleware to determine whether any HTTP metrics have been defined
    #
    # @return [Boolean] if HTTP metrics have been defined
    def http_metrics? ; @http_metrics ; end

    private
    # Delegate methods to UnicornMetrics::Registry
    #
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

require 'raindrops'
require 'unicorn_metrics/registry'
require 'unicorn_metrics/version'
require 'unicorn_metrics/counter'
require 'unicorn_metrics/timer'
require 'unicorn_metrics/default_http_metrics'
require 'unicorn_metrics/request_counter'
require 'unicorn_metrics/request_timer'
require 'unicorn_metrics/response_counter'
require 'forwardable'

