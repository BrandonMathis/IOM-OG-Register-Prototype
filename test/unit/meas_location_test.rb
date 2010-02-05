require 'test_helper'

class MeasLocationTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:meas_location)
  end
end
