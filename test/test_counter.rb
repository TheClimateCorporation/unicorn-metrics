require 'test_helper'

describe UnicornMetrics::Counter do
  before do
    @counter = UnicornMetrics::Counter.new("test_counter")
    @counter.reset
  end

  describe "#type" do
    it "returns 'counter'" do
      @counter.type.must_equal 'counter'
    end
  end

  describe "#value" do
    it "returns the internal count" do
      @counter.value.must_equal 0
    end
  end

  describe "#increment" do
    it "increments the counter value" do
      5.times { @counter.increment }
      @counter.value.must_equal 5
    end
  end

  describe "#decrement" do
    it "decrements the counter value" do
      5.times { @counter.increment }
      5.times { @counter.decrement }
      @counter.value.must_equal 0
    end
  end

  describe "#reset" do
    it "resets the counter value" do
      5.times { @counter.increment }
      @counter.reset
      @counter.value.must_equal 0
    end
  end

  describe "#as_json" do
    it "returns the JSON representation of the object as a hash" do
      hash = {
        @counter.name => {
          "type"  => @counter.type,
          "value" => @counter.value
        }
      }

      @counter.as_json.must_equal hash
    end
  end

  # REFACTOR: This test is very slow
  describe "forking" do
    it "can be shared across processes" do
      2.times { fork { @counter.increment ; exit } }
      Process.waitall
      @counter.value.must_equal 2
    end
  end
end
