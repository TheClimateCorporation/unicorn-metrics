# Borrowing nomenclature from http://metrics.codahale.com/
#
# To support a cleaner interface, the UnicornMetrics module delegates to the Registry
# for supported methods. Methods should not be called directly on this module

# UnicornMetrics::Registry is a container for Metrics
# @private
module UnicornMetrics::Registry

  # Map metrics types to class names
  METRIC_TYPES = {
    :counter          => 'Counter',
    :timer            => 'Timer',
    :response_counter => 'ResponseCounter',
    :request_counter  => 'RequestCounter',
    :request_timer    => 'RequestTimer'
  }

  class << self

    # Return a hash of metrics that have been defined
    #
    # @return [Hash] a metric name to metric object
    def metrics
      @metrics ||= {}
    end

    # Register a new metric. Arguments are optional. See metric class definitions.
    #
    # @param type [Symbol] underscored metric name
    # @param name [String] string representing the metric name
    # @return [Counter, Timer, ResponseCounter, RequestCounter, RequestTimer]
    def register(type, name, *args)
      type          = METRIC_TYPES.fetch(type) { raise "Invalid type: #{type}" }
      validate_name!(name)
      metric        = UnicornMetrics.const_get(type).new(name,*args)
      metrics[name] = metric
      define_getter(name)

      metric
    end

    # @return [Hash] default JSON representation of metrics
    def as_json(*)
      metrics.inject({}) do |hash, (name, metric)|
        hash.merge(metric.as_json)
      end
    end

    private
    # Convenience methods to return the stored metrics.
    # Allows the use of names with spaces, dots, and dashes, which are \
    # replaced by an underscore:
    #
    # def UnicornMetrics::Registry.stat_name
    #   metrics.fetch('stat_name')
    # end
    #
    def define_getter(name)
      define_singleton_method(format_name(name)) { metrics.fetch(name) }
    end

    # Replace non-word characters with '_'
    def format_name(name)
      name.gsub(/\W/, '_')
    end

    # @raise [ArgumentError] if the metric name is in use
    def validate_name!(name)
      if metrics.fetch(name,false)
        raise ArgumentError, "The name, '#{name}', is in use."
      end
    end
  end
end
