# Counter defined to keep count of method types of http requests
# Requires the UnicornMetrics::Middleware

class UnicornMetrics::RequestCounter < UnicornMetrics::Counter
  attr_reader :path, :method_name

  METHOD_COUNTERS = []

  # :method_name is a string
  # :path is regex pattern
  def initialize(name, method_name, path=nil)
    @path        = path
    @method_name = method_name.to_s
    METHOD_COUNTERS << self
    super(name)
  end

  def self.counters ; METHOD_COUNTERS ; end

  def self.notify(meth_val, path)
    counters.each { |c| c.increment if c.path_method_match?(meth_val, path) }
  end

  def path_method_match?(meth_val, path_val)
    path_matches?(path_val) && method_matches?(meth_val)
  end

  private
  def path_matches?(val)
    !!(path =~ val) || path.nil?
  end

  def method_matches?(val)
    method_name.upcase == val.to_s
  end
end
