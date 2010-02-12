require 'test_helper'

class AssetObserverTest < ActiveSupport::TestCase
  context "with an asset" do
    setup do
      @asset = Factory.create(:asset)
      @segment = Factory.create(:segment)
    end

    context "when it is installed into a segment" do
      setup do
        flexmock(AssetObserver).should_receive(:install).with(@asset, @segment).once
        @asset.installed_on_segment = @segment
        @asset.save
      end
      should "have the asset installed on the segment" do
        assert_equal @segment, @asset.installed_on_segment
      end

      should_eventually "have the asset as the segment's installed asset" do
        assert_equal @asset, @segment.installed_asset
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
        flexmock(AssetObserver).should_receive(:remove).once
        @asset.installed_on_segment = nil
        @asset.save
      end
      should "have no installed on segment" do
        assert_nil @asset.installed_on_segment
      end
      should_eventually "not have an installed asset on the segment" do
        assert_nil @segment.installed_asset
      end
    end
  end

  context "with an asset and a segment" do
    setup do
      @asset = Factory.create(:asset)
      @segment = Factory.create(:segment)
    end

    context "calling the observer install" do
      setup do
        AssetObserver.install(@asset, @segment)
      end

      should_change "Event.count", :by => 1
      
      context "generates an event" do
        setup do
          @event = Event.first(:conditions => { "monitored_object.guid" => @asset.guid, "for.guid" => @segment.guid })
        end
        should "for this asset and segment" do
          assert @event
        end
        should "have created an install event" do
          assert_equal "Install Event", @event.object_type.user_name
        end
      end
    end

    context "calling the observer remove" do
      setup do
        AssetObserver.remove(@asset, @segment)
      end

      should_change "Event.count", :by => 1
      
      context "generates an event" do
        setup do
          @event = Event.first(:conditions => { "monitored_object.guid" => @asset.guid, "for.guid" => @segment.guid })
        end
        should "for this asset and segment" do
          assert @event
        end
        should "have created an remove event" do
          assert_equal "Remove Event", @event.object_type.user_name
        end
      end
    end
  end
end
