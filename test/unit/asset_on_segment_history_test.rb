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
  context "duplicating the AOSH" do
    setup do
      @hist1 = Factory.create(:asset_on_segment_history)
      @asset = Factory.create(:asset)
      @hist1.install(@asset)
      @hist2 = @hist1.dup_entity
    end
    
    should "create two separate objects" do
      assert_not_equal @hist1, @hist2
      assert_equal @hist1.guid, @hist2.guid
    end
    
    should "create histories with identical information" do
      @hist1.field_names.each do |field|
        assert_equal @hist1.send("#{field}"), @hist2.send("#{field}") unless field == :last_edited
      end
    end
    
    should "copy AOSH assets" do
      @hist1.assets.each do |asset|
        asset.field_names.each do |field|
          assert_equals @hist1.send("#{field}"), @hist2.send("#{field}")
        end
      end
    end
    
    should "create histories with logged assets that have identical information" do
      @hist1.logged_asset.field_names do |field|
        assert_equal @hist1.send("#{field}"), @hist2.send("#{field}")
      end
    end
    
    should "copy start time" do
      assert @hist2.start
    end
    
    context "after uninstall" do
      setup do
        @hist1.uninstall()
        @hist2 = @hist1.dup_entity
      end
    
      should "copy end time" do
        assert @hist2.end
      end
      
      should "create logged assets with identical information" do
        @hist1.logged_asset.field_names do |field|
          assert_equal @hist1.send("#{field}"), @hist2.send("#{field}")
          assert_not_equal @hist1, @hist2
        end
      end
    end
    
    context "and generate unique guids" do
      setup do
        @hist2 = @hist1.dup_entity(:gen_new_guids => true)
      end
      
      should "create unique guids for AOSHs" do
        assert_not_equal @hist1.guid, @hist2.guid
      end
      
      should "NOT create unique guids for AOSH logged assets" do
        assert_equal @hist1.logged_asset.guid, @hist2.logged_asset.guid
      end
    end
  end    
end
