require 'test_helper'

class TopologyAssetTest < ActiveSupport::TestCase
  context "with a simple topology asset" do
    setup do
      @topology = Factory.create(:topology_asset)
    end

    should "be valid" do
      assert_valid @topology
    end

    should "have a nil entry point" do
      assert_nil @topology.entry_point
    end
  end

  should "be valid from factory" do
    assert_valid Factory.create(:topology_asset)
  end

  context "assigning an entry point" do
    setup do
      @entry_point = Factory.create(:network_connection)
      @topology = Factory.create(:topology_asset, :entry_point => @entry_point)
    end
    should "be assigned" do
      assert_equal @entry_point, @topology.entry_point
    end
    should "still be assinged when I reload it" do
      assert_equal @entry_point, TopologyAsset.find_by_guid(@topology.guid).entry_point
    end
  end
end
