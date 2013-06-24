# UnicornMetrics::Middleware extends the existing Raindrops::Middleware class
#
require 'unicorn_metrics' unless defined?(UnicornMetrics)
require 'raindrops'

class UnicornMetrics::Middleware < Raindrops::Middleware
  # * :metrics_path - HTTP endpoint used for reading application metrics
  # * registry is a container for collecting application metrics

  def initialize(app, opts = {})
    @registry     = UnicornMetrics::Registry
    @metrics_path = opts[:metrics] || "/metrics"
    super
  end

  def call(env)
    env['PATH_INFO'] == @metrics_path and return metrics_response

    response = super
    #=> [  status, headers, <#Raindrops::Middleware::Proxy> ]
    # Proxy is a wrapper around the response body

    collect_http_metrics(env, response) if UnicornMetrics.http_metrics?
    response
  end

  private
  def metrics_response
    body = @registry.as_json.merge(raindrops).to_json

    headers = {
      "Content-Type" => "application/json",
      "Content-Length" => body.size.to_s,
    }
    [ 200, headers, [ body ] ]
  end

  def collect_http_metrics(env, response)
    method, path = env['REQUEST_METHOD'], env['PATH_INFO']
    status = response[0]

    UnicornMetrics::ResponseCounter.notify(status, path)
    UnicornMetrics::RequestCounter.notify(method, path)
  end

  # Provide Raindrops::Middleware statistics in the metrics JSON response
  # @stats is defined in the Raindrops::Middleware class

  # * calling - the number of application dispatchers on your machine
  # * writing - the number of clients being written to on your machine
  def raindrops
    {
      "raindrops.calling" => {
        "type" => "gauge",
        "value" => @stats.calling
      },
      "raindrops.writing" => {
        "type" => "gauge",
        "value" => @stats.writing
      }
    }.merge(listener_stats)
  end

  # Supporting additional stats collected by Raindrops for Linux platforms
  def listener_stats(listeners={})
    if defined?(Raindrops::Linux.tcp_listener_stats)
      Raindrops::Linux.tcp_listener_stats(@tcp).each do |addr,stats|
        listeners["raindrops.#{addr}.active"] = "#{stats.active}"
        listeners["raindrops.#{addr}.queued"] = "#{stats.queued}"
      end if @tcp
      Raindrops::Linux.unix_listener_stats(@unix).each do |addr,stats|
        listeners["raindrops.#{addr}.active"] = "#{stats.active}"
        listeners["raindrops.#{addr}.queued"] = "#{stats.queued}"
      end if @unix
    end
    listeners
  end
end
