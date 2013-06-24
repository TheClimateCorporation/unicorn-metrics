# Borrowing nomenclature from http://metrics.codahale.com/
# Metrics::Registry is a container for Metrics

class UnicornMetrics::Registry
  METRIC_TYPES = {
    :counter => 'Counter',
    :response_counter => 'ResponseCounter',
    :request_counter => 'RequestCounter'
  }

  class << self
    def metrics
      @metrics ||= {}
    end

    # Register a new metric
    def register(type, name, *args)
      type          = METRIC_TYPES.fetch(type) { raise "Invalid type: #{type}" }
      validate_name!(name)
      metric        = UnicornMetrics.const_get(type).new(name,*args)
      metrics[name] = metric
      define_getter(name)

      metric
    end

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

    def validate_name!(name)
      if metrics.fetch(name,false)
        raise ArgumentError, "The name, '#{name}', is in use."
      end
    end
  end
end
