require 'test_helper'

class AssetObserverTest < ActiveSupport::TestCase
  context "with an asset" do
    setup do
      @asset = Factory.create(:asset)
      @segment = Factory.create(:segment)
    end

    context "when it is installed into a segment" do
      setup do
        @asset.installed_on_segment = @segment
        @asset.save
      end
      before_should "fire off the asset observer's install event" do
        flexmock(AssetObserver).should_receive(:install).with(@asset, @segment).once
      end
    end
  end

  context "with an asset already installed on segment" do
    setup do
      assert @segment = Factory.create(:segment)
      @asset = Factory.create(:asset, :installed_on_segment => @segment)
    end

    should "be installed on a segment" do
      assert_equal @segment, @asset.installed_on_segment
    end
    context "when the asset is removed from the segment" do
      setup do
        @asset.installed_on_segment = nil
        @asset.save
      end
      should "have no installed on segment" do
        assert_nil @asset.installed_on_segment
      end
      should_eventually "not have an installed asset on the segment" do
        assert_nil @segment.installed_asset
      end
      before_should "fire of the asset observer's remove envent" do
        flexmock(AssetObserver).should_receive(:remove).once
      end
    end
  end
end
