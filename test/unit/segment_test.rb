require 'test_helper'

class SegmentTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:segment)
  end

  should "support multiple meas locations" do
    assert_valid Factory.create(:segment,
                                :meas_locations => [Factory.create(:meas_location), 
                                                    Factory.create(:meas_location)])
  end
end
