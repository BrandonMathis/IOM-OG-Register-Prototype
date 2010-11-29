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
      assert @hist.start
    end
    context "then recording an uninstall event" do
      setup do
        @hist.uninstall(@asset)
      end
      should "generate an end time" do
        assert @hist.end 
      end
    end
  end
  context "duplicating the AOSH" do
    setup do
      @asset = Factory.create(:asset)
      @logged_asset = Factory.create(:asset)
      @hist1 = Factory.create(:asset_on_segment_history, :assets => [@asset], :logged_asset => @logged_asset, :start => CcomEntity.get_time, :end => CcomEntity.get_time)
      @hist2 = @hist1.dup_entity
    end
    
    should "create two separate objects" do
      assert_not_equal @hist1, @hist2
      assert_equal @hist1.guid, @hist2.guid
    end
    
    should "create histories with identical information" do
      @hist1.field_names.each do |field|
        if @hist1.editable_attribute_names.include?(field)
          assert_equal @hist1.send("#{field}"), @hist2.send("#{field}")
        end
      end
    end
    
    should "copy AOSH assets" do
      @hist1.assets.first.field_names.each do |field|
        assert_equal @hist1.assets.first.send("#{field}"), @hist2.assets.first.send("#{field}") unless field == :last_edited
      end
    end
    
    should "create histories with logged assets that have identical information" do
      @hist1.logged_asset.field_names do |field|
        assert_equal @hist1.send("#{field}"), @hist2.send("#{field}")
      end
    end
      
    should "NOT create unique guids for AOSH logged assets" do
      assert_equal @hist1.logged_asset.guid, @hist2.logged_asset.guid
    end
  end    
end
