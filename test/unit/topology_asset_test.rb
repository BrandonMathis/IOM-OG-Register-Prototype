require 'test_helper'

class TopologyAssetTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:topology_asset)
  end

  context "with a network connection" do
    setup do
      @entry_point = Factory.create(:network_connection)
      assert_valid @topology = Factory.create(:topology_asset, :entry_point => @entry_point)
    end
    should "have an entry point as a network connection" do
      assert_equal @entry_point, @topology.entry_point
    end

    context "setting a new entry point" do
      setup do
        @new_entry_point = Factory.create(:network_connection)
        @topology.entry_point = @new_entry_point
      end

      should "be the new entry point" do
        assert_equal @new_entry_point, @topology.entry_point
      end
    end
  end
end
