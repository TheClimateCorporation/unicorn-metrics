# Counter defined to keep count of status codes of http responses
# Requires the UnicornMetrics::Middleware

class UnicornMetrics::ResponseCounter < UnicornMetrics::Counter
  attr_reader :path, :status_code

  STATUS_COUNTERS = []

  # :status_code is a regex pattern
  # :path is regex pattern
  def initialize(name, status_code, path=nil)
    @path        = path
    @status_code = status_code
    STATUS_COUNTERS << self
    super(name)
  end

  def self.counters ; STATUS_COUNTERS ; end

  def self.notify(status, path)
    counters.each { |c| c.increment if c.path_status_match?(status, path) }
  end

  def path_status_match?(stat_val,path_val)
    status_matches?(stat_val) && path_matches?(path_val)
  end

  private
  def path_matches?(val)
    path.nil? || !!(path =~ val)
  end

  def status_matches?(val)
    !!(status_code =~ val.to_s)
  end
end
