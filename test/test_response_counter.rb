require 'test_helper'

describe UnicornMetrics::ResponseCounter do
  before do
    @counter = UnicornMetrics::ResponseCounter.new("test_counter", /[2]\d{2}/)
    @counter.reset
  end

  describe ".counters" do
    it "returns a collection of current ResponseCounter instances" do
      UnicornMetrics::ResponseCounter.counters.must_include @counter
    end
  end

  describe ".notify" do
    it "increments all existing counters that match a status code and path" do
      UnicornMetrics::ResponseCounter.notify('200','/')
      @counter.value.must_equal 1
    end
  end

  describe "#path_status_match?" do
    context "when path is nil (not specified)" do
      context "when status name matches" do
        it "returns true" do
          @counter.path_status_match?('200', '/anything').must_equal true
        end
      end

      context "when status name does not match" do
        it "returns false" do
          @counter.path_status_match?('400', '/anything').must_equal false
        end
      end
    end

    context "when path is not nil (it is set)" do
      before { @counter.instance_variable_set(:@path, /\/something/) }
      after  { @counter.instance_variable_set(:@path, nil) }

      context "when status matches" do
        context "when patch matches" do
          it "returns true" do
            @counter.path_status_match?('200', '/something').must_equal true
          end
        end

        context "when patch does not match" do
          it "returns false" do
            @counter.path_status_match?('200', '/bla').must_equal false
          end
        end
      end
    end
  end
end
