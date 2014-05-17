require 'test_helper'

describe UnicornMetrics::Gauge do

  before do
    def test_value
      193
    end

    @gauge = UnicornMetrics::Gauge.new("test_gauge") { test_value }
  end

  describe "#initialize" do
    it "raises ArgumentError when not passed a blocked" do
      ->{UnicornMetrics::Gauge.new("initialize_test")}.must_raise ArgumentError
    end
  end

  describe "#value" do
    it "returns the result of executing the block" do
      @gauge.value.must_equal 193
    end
  end

  describe "#type" do
    it "returns 'gauge'" do
      @gauge.type.must_equal 'gauge'
    end
  end

  describe "#as_json" do
    it "returns the JSON representation of the object as a hash" do
      hash = {
        @gauge.name => {
          "type"  => @gauge.type,
          "value" => @gauge.value
        }
      }

      @gauge.as_json.must_equal hash
    end
  end
end
