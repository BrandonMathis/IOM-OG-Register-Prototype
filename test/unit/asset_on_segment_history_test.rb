require 'test_helper'

class AssetOnSegmentHistoryTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:asset_on_segment_history)
  end
  
  context "creating an asset history" do
    setup do
      @hist = Factory.create(:asset_on_segment_history)
      @asset = Factory.create(:asset)
      @hist.install(@asset)
    end
    should "give the history a guid" do
      assert_not_nil @hist.g_u_i_d
    end
    should "make history as asset's asset_on_segment_history" do
      assert_equal @hist, @asset.asset_on_segment_history
    end
    should "properly store the correct asset" do
      assert @hist.assets.include? @asset
    end
  end
  
  context "recording an install event" do
    setup do
      @hist = Factory.create(:asset_on_segment_history)
      @asset = Factory.create(:asset)
      @hist.install(@asset)
    end
    should "generate a start time" do
      assert Time.parse(@hist.start) < Time.now 
    end
    context "then recording an uninstall event" do
      setup do
        @hist.uninstall()
      end
      should "generate an end time" do
        assert Time.parse(@hist.end) < Time.now 
      end
    end
  end
end
