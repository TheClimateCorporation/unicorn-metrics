module UnicornMetrics::DefaultHttpMetrics
  def register_default_http_counters
    [
      ["responses.2xx", /[2]\d{2}/], ["responses.3xx", /[3]\d{2}/],
      ["responses.4xx", /[4]\d{2}/], ["responses.5xx", /[5]\d{2}/]
    ].each { |c| register(:response_counter, *c) }
  end

  def register_default_http_timers
    [
      ['requests.GET', 'GET'], ['requests.POST', 'POST'],
      ['requests.DELETE', 'DELETE'], ['requests.HEAD', 'HEAD'],
      ['requests.PUT', 'PUT']
    ].each { |c| register(:request_timer, *c) }
  end
end
