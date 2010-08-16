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
    should "make history as asset's asset_on_segment_history" do
      assert_equal @hist, @asset.asset_on_segment_history
    end
    should "properly store the correct asset" do
      assert @hist.assets.include? @asset
    end
  end
end
