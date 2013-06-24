require 'test_helper'

describe UnicornMetrics::RequestCounter do
  before do
    @counter = UnicornMetrics::RequestCounter.new("test_counter", 'POST')
    @counter.reset
  end

  describe ".counters" do
    it "returns a collection of current RequestCounter instances" do
      UnicornMetrics::RequestCounter.counters.must_include @counter
    end
  end

  describe ".notify" do
    it "increments all existing counters that match an http method and path" do
      UnicornMetrics::RequestCounter.notify('POST','/')
      @counter.value.must_equal 1
    end
  end

  describe "#path_method_match?" do
    context "when path is nil (not specified)" do
      context "when method name matches" do
        it "returns true" do
          @counter.path_method_match?('POST', '/anything').must_equal true
        end
      end

      context "when method name does not match" do
        it "returns false" do
          @counter.path_method_match?('GET', '/anything').must_equal false
        end
      end
    end

    context "when path is not nil (it is set)" do
      before { @counter.instance_variable_set(:@path, /\/something/) }
      after  { @counter.instance_variable_set(:@path, nil) }

      context "when method matches" do
        context "when patch matches" do
          it "returns true" do
            @counter.path_method_match?('POST', '/something').must_equal true
          end
        end

        context "when patch does not match" do
          it "returns false" do
            @counter.path_method_match?('POST', '/bla').must_equal false
          end
        end
      end
    end
  end
end
