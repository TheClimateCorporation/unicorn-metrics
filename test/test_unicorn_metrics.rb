require 'test_helper'

describe UnicornMetrics do
  describe "::registry" do
    it "returns the UnicornMetrics::Registry object" do
      UnicornMetrics.registry.must_equal UnicornMetrics::Registry
    end
  end

  describe "::configure" do
    it "yields self" do
     ->{ UnicornMetrics.configure {|u| print u}}.must_output 'UnicornMetrics'
    end
  end

  describe "::http_metrics=" do
    context "when arg is false" do
      it "should not extend Registry with DefaultHttpCounters module" do
        UnicornMetrics.registry.wont_respond_to :register_default_http_counters
      end
    end

    context "when arg is true" do
      before { UnicornMetrics.http_metrics = true }

      it "extends Registry with DefaultHttpMetrics module" do
        UnicornMetrics.registry.must_respond_to :register_default_http_counters
        UnicornMetrics.registry.must_respond_to :register_default_http_timers
      end

      it "registers the default http counters" do
        UnicornMetrics.registry.metrics.keys.size.must_equal 9
      end
    end
  end

  it "delegates unknown methods to Registry" do
    methods       = UnicornMetrics.registry.methods(false)
    respond_count = 0
    methods.each { |m| respond_count+=1 if UnicornMetrics.respond_to?(m) }
    respond_count.must_equal methods.size
  end
end
