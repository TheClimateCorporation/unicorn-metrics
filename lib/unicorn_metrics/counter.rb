# UnicornMetrics::Counter is an atomic counter that conveniently wraps the Raindrops::Struct
#
class UnicornMetrics::Counter
  extend Forwardable

  attr_reader :name

  class Stats < Raindrops::Struct.new(:value) ; end

  # Delegate getter and setter to @stats
  def_instance_delegator :@stats, :value

  # Provide #increment and #decrement by delegating to @stats
  def_instance_delegator :@stats, :incr_value, :increment
  def_instance_delegator :@stats, :decr_value, :decrement

  # @param name [String] user-defined name
  def initialize(name)
    @name  = name
    @stats = Stats.new
  end

  # Reset the counter
  def reset
    @stats.value = 0
  end

  def type
    "counter"
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
