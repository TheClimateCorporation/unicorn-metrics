# UnicornMetrics::Timer keeps track of total time and the count of 'ticks'
# A simple rate of average of ticks over time elapsed can be calculated this way.
# For more advanced metrics (e.g., 1/5/15min moving averages) this data should be reported to an intelligent metric store (i.e. Graphite)
#
class UnicornMetrics::Timer
  extend Forwardable

  attr_reader :name

  # The Raindrops::Struct can only hold unsigned long ints (0 -> 4,294,967,295)
  # Since we usually care about ms in a web application, \
  # let's store 3 significant digits after the decimal
  EXPONENT = -3

  class Stats < Raindrops::Struct.new(:count, :mantissa) ; end

  def_instance_delegators :@stats, :mantissa, :count

  # @param name [String] user-defined name
  def initialize(name)
    @name  = name
    @stats = Stats.new
  end

  def type
    "timer"
  end

  # @param elapsed_time [Numeric] in seconds
  def tick(elapsed_time)
    elapsed_time = (elapsed_time * 10**-EXPONENT).to_i

    @stats.mantissa = mantissa + elapsed_time
    @stats.incr_count
  end

  # Reset the timer
  def reset
    @stats.mantissa = 0 and @stats.count = 0
  end

  # @return [Numeric] total elapsed time
  def sum
    (mantissa * 10**EXPONENT).to_f.round(-EXPONENT)
  end

  # @return [Hash] JSON representation of the object
  def as_json(*)
    {
      name => {
        "type"  => type,
        "sum"   => sum,
        "value" => count
      }
    }
  end
end
