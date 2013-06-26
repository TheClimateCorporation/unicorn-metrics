# UnicornMetrics::Middleware extends the existing Raindrops::Middleware class
#
require 'unicorn_metrics' unless defined?(UnicornMetrics)
require 'raindrops'
require 'benchmark'

class UnicornMetrics::Middleware < Raindrops::Middleware

  # @param opts [Hash] options hash
  # @option opts [String] :metrics the HTTP endpoint that exposes the application metrics
  def initialize(app, opts = {})
    @registry     = UnicornMetrics::Registry
    @metrics_path = opts[:metrics] || "/metrics"
    super
  end

  def call(env)
    return metrics_response if env['PATH_INFO'] == @metrics_path

    response = nil
    time = Benchmark.realtime do
      response = super
      #=> [  status, headers, <#Raindrops::Middleware::Proxy> ]
      # Proxy is a wrapper around the response body
    end
    collect_http_metrics(env, response, time) if UnicornMetrics.http_metrics?
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

  def collect_http_metrics(env, response, elapsed_time)
    method, path = env['REQUEST_METHOD'], env['PATH_INFO']
    status = response[0]

    UnicornMetrics::ResponseCounter.notify(status, path)
    UnicornMetrics::RequestTimer.notify(method, path, elapsed_time)
  end

  # Provide Raindrops::Middleware statistics in the metrics JSON response
  # `@stats` is defined in the Raindrops::Middleware class

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
    }.merge(total_listener_stats)
  end

  # Supporting additional stats collected by Raindrops for Linux platforms
  # `@tcp` and `@unix` are defined in Raindrops::Middleware
  def total_listener_stats(listeners={})
    if defined?(Raindrops::Linux.tcp_listener_stats)
      listeners.merge!(raindrops_tcp_listener_stats) if @tcp
      listeners.merge!(raindrops_unix_listener_stats) if @unix
    end
    listeners
  end

  def raindrops_tcp_listener_stats
    hash = {
      "raindrops.tcp.active" => { type: :gauge, value: 0 },
      "raindrops.tcp.queued" => { type: :gauge, value: 0 }
    }
    Raindrops::Linux.tcp_listener_stats(@tcp).each do |_, stats|
      hash["raindrops.tcp.active"][:value] += stats.active.to_i
      hash["raindrops.tcp.queued"][:value] += stats.queued.to_i
    end
    hash
  end

  def raindrops_unix_listener_stats
    hash = {
      "raindrops.unix.active" => { type: :gauge, value: 0 },
      "raindrops.unix.queued" => { type: :gauge, value: 0 }
    }
    Raindrops::Linux.unix_listener_stats(@unix).each do |_, stats|
      hash["raindrops.unix.active"][:value] += stats.active.to_i
      hash["raindrops.unix.queued"][:value] += stats.queued.to_i
    end
    hash
  end

  # NOTE: The 'total' is being used in favor of returning stats for \
  # each listening address, which was the default in Raindrops
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
