require 'test_helper'

class TopologyAssetTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:topology_asset)
  end

  should "have a network" do
    network = Factory.create(:network)
    assert_valid topology = Factory.create(:topology_asset, :network => network)
    assert_equal network, topology.network
  end
end
