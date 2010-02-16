require 'test_helper'

class TopologyAssetTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:topology_asset)
  end

  should "have a functional location" do
    functional_location = Factory.create(:functional_location)
    assert_valid topology = Factory.create(:topology_asset, :functional_location => functional_location)
    assert_equal functional_location, topology.functional_location
  end
end
