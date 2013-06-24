# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require 'unicorn_metrics/middleware'

# Replaces Raindrops::Middleware
use UnicornMetrics::Middleware, :listeners => %w(0.0.0.0:7180 /tmp/clemens.sock), :metrics => "/metrics"

run ApplicationName::Application
