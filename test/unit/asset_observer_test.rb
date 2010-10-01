require 'test_helper'

class AssetObserverTest < ActiveSupport::TestCase

  context "with an asset and a segment" do
    setup do
      @asset = Factory.create(:asset)      
      @segment = Factory.create(:segment)
      @hist = Factory.create(:asset_on_segment_history, :segment => @segment)
    end

    context "calling the observer install" do
      setup do
        flexmock(AssetObserver).should_receive(:publish).with(ActualEvent).once
        AssetObserver.install(@asset, @hist)
      end

      should_change("event count", :by => 1) { ActualEvent.count }
      
      context "generates a findable event" do
        setup do
          @event = ActualEvent.first(:conditions => { "monitored_object_id" => @asset._id, "hist_id" => @hist._id })
        end
        should "not be nil" do
          assert_not_nil @event
        end
        should "have created an install event" do
          assert_equal "Installation of Asset on Segment", @event.type.name
        end
      end
    end

    context "calling the observer remove" do
      setup do
        flexmock(AssetObserver).should_receive(:publish).with(ActualEvent).once
        AssetObserver.remove(@asset, @hist)
      end

      should_change("event count", :by => 1) { ActualEvent.count }
      
      context "generates an event" do
        setup do
          @event = ActualEvent.first(:conditions => { "monitored_object_id" => @asset._id, "hist_id" => @hist._id })
        end
        should "for this asset and segment" do
          assert @event
        end
        should "have created an remove event" do
          assert_equal "Removal of Asset on Segment", @event.type.name
        end
      end
    end
  end

  should "invoke net http post when publishing an event" do
    @event = Factory.create(:actual_event)
    response = AssetObserver.publish(@event)
    assert_requested(:post, POSTBACK_URI, :times => 1) { |req| req.body == @event.to_xml }
  end
end
