require 'test_helper'

describe UnicornMetrics::Timer do
  before do
    @timer = UnicornMetrics::Timer.new("test_timer")
    @timer.reset
  end

  describe "#type" do
    it "returns 'timer'" do
      @timer.type.must_equal 'timer'
    end
  end

  context "when initialized" do
    describe "#sum" do
      it "must be zero" do
        @timer.sum.must_equal 0.0
      end
    end

    describe "#count" do
      it "must be zero" do
        @timer.count.must_equal 0
      end
    end
  end

  context "when ticked" do
    describe "#sum" do
      it "returns sum + elapsed time" do
        @timer.tick(5)
        @timer.sum.must_equal 5.0
      end
    end

    describe "#count" do
      it "returns the count of ticks" do
        @timer.tick(5)
        @timer.count.must_equal 1
      end
    end
  end

  describe "#reset" do
    it "resets count and sum" do
      5.times { @timer.tick(5) }
      @timer.reset
      @timer.sum.must_equal 0
      @timer.count.must_equal 0
    end
  end

  describe "#as_json" do
    it "returns the JSON representation of the object as a hash" do
      hash = {
        @timer.name => {
          "type"  => @timer.type,
          "sum"   => @timer.sum,
          "count" => @timer.count
        }
      }

      @timer.as_json.must_equal hash
    end
  end

  describe "forking" do
    it "can be shared across processes" do
      2.times { fork { @timer.tick(5) ; exit } }
      Process.waitall
      @timer.sum.must_equal 10.0
      @timer.count.must_equal 2
    end
  end
end
