class UnicornMetrics::Gauge

  attr_reader :name

  # @param name [String] user-defined name
  # @param &block evaluated to get the gauges instantaneous value
  def initialize(name, &block)
    unless block_given?
      raise ArgumentError, "UnicornMetrics: Gauge requires a block argument"
    end
    @name  = name
    @block = block
  end

  # @return [Object]
  def value
    @block.call
  end

  def type
    "gauge"
  end

  # @return [Hash] JSON representation of the object
  def as_json(*)
    {
      name => {
        "type"  => type,
        "value" => value
      }
    }
  end
end
