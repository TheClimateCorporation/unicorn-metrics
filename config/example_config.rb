UnicornMetrics.configure do |c|
  # Example:
  # c.register(:counter, "counter_one")
  # UnicornMetrics.counter_one.increment
  #
  # Names can be separated by dots and spaces, but the getter methods will use underscores:
  # c.register(:counter, "counter.one")
  # UnicornMetrics.counter_one.increment

  # Set to true to create counters for endpoint statistics
  # Several high-level statistics are provided for free:
  #
  # "responses.4xx", "responses.5xx", "responses.2xx", "responses.3xx"
  # "requests.POST", "requests.PUT", "requests.GET", "requests.DELETE"
  #
  c.http_metrics = true # Default false

  # Register a timer for GET requests to URIs that match api/v1/path/<id> 
  c.register(:request_timer, "api/v1/path/id.GET", 'GET', %r{\/api\/v1\/path\/\d+})

  # Register a counter for all 200 responses (path not specified)
  c.register(:response_counter, "responses.200", /200/)
end
