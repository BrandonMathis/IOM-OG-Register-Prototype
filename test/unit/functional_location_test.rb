require 'test_helper'

class FunctionalLocationTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:functional_location)
  end

  # should "have many functional locations" do
  #   sub_location = Factory.create(:functional_location)
  #   assert_valid functional_location = Factory.create(:functional_location, :functional_locations => [sub_location])
  #   assert functional_location.functional_locations.include?(sub_location)
  # end
end
