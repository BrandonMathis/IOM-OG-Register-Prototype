require 'test_helper'

class AssetObserverTest < ActiveSupport::TestCase

  context "with an asset and a segment" do
    setup do
      @asset = Factory.create(:asset)
      @segment = Factory.create(:segment)
    end

    context "calling the observer install" do
      setup do
        flexmock(AssetObserver).should_receive(:publish).with(Event).once
        AssetObserver.install(@asset, @segment)
      end

      should_change("event count", :by => 1) { Event.count }
      
      context "generates a findable event" do
        setup do
          @event = Event.first(:conditions => { "monitored_object_id" => @asset._id, "for_id" => @segment._id })
        end
        should "not be nil" do
          assert_not_nil @event
        end
        should "have created an install event" do
          assert_equal "Install Event", @event.type.name
        end
      end
    end

    context "calling the observer remove" do
      setup do
        flexmock(AssetObserver).should_receive(:publish).with(Event).once
        AssetObserver.remove(@asset, @segment)
      end

      should_change("event count", :by => 1) { Event.count }
      
      context "generates an event" do
        setup do
          @event = Event.first(:conditions => { "monitored_object_id" => @asset._id, "for_id" => @segment._id })
        end
        should "for this asset and segment" do
          assert @event
        end
        should "have created an remove event" do
          assert_equal "Remove Event", @event.type.name
        end
      end
    end
  end

  should "invoke net http post when publishing an event" do
    @event = Factory.create(:event)
    response = AssetObserver.publish(@event)
    assert_requested(:post, POSTBACK_URI, :times => 1) { |req| req.body == @event.to_xml }
  end
end
