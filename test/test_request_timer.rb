require 'test_helper'

describe UnicornMetrics::RequestTimer do
  before do
    @timer = UnicornMetrics::RequestTimer.new("test_timer", 'POST')
    @timer.reset
  end

  describe ".timers" do
    it "returns a collection of current RequestTimer instances" do
      UnicornMetrics::RequestTimer.timers.must_include @timer
    end
  end

  describe ".notify" do
    it "ticks all existing timers that match an http method and path" do
      UnicornMetrics::RequestTimer.notify('POST','/', 10.0)
      @timer.sum.must_equal 10.0
    end
  end

  describe "#path_method_match?" do
    context "when path is nil (not specified)" do
      context "when method name matches" do
        it "returns true" do
          @timer.path_method_match?('POST', '/anything').must_equal true
        end
      end

      context "when method name does not match" do
        it "returns false" do
          @timer.path_method_match?('GET', '/anything').must_equal false
        end
      end
    end

    context "when path is not nil (it is set)" do
      before { @timer.instance_variable_set(:@path, /\/something/) }
      after  { @timer.instance_variable_set(:@path, nil) }

      context "when method matches" do
        context "when patch matches" do
          it "returns true" do
            @timer.path_method_match?('POST', '/something').must_equal true
          end
        end

        context "when patch does not match" do
          it "returns false" do
            @timer.path_method_match?('POST', '/bla').must_equal false
          end
        end
      end
    end
  end
end
