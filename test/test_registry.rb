require 'test_helper'

describe UnicornMetrics::Registry do
  describe "METRIC_TYPES" do
    it "returns a hash that maps type symbols to class names" do
      hash = {
        :gauge            => 'Gauge',
        :counter          => 'Counter',
        :timer            => 'Timer',
        :response_counter => 'ResponseCounter',
        :request_counter  => 'RequestCounter',
        :request_timer    => 'RequestTimer'
      }
      UnicornMetrics::Registry::METRIC_TYPES.must_equal hash
    end
  end

  describe ".register" do
    before { UnicornMetrics.register(:counter,"test-counter") }
    after  { UnicornMetrics.metrics.delete("test-counter")}

    it "initializes and stores a new metric object" do
      UnicornMetrics.metrics.fetch("test-counter").must_be_instance_of UnicornMetrics::Counter
    end

    it "defines getter method from the name of the metric with non-word chars replaced by '_'" do
      UnicornMetrics.metrics.fetch("test-counter").must_be_same_as UnicornMetrics.test_counter
    end

    it "raises an error if a name is used twice" do
      ->{UnicornMetrics.register(:counter, "test-counter")}.must_raise ArgumentError
    end
  end
end

