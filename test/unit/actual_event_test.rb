require 'test_helper'

class ActualEventTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:actual_event)
  end

  should "support assigning an object type" do
    type = Factory.create(:type, :name => "Install Event")
    assert_valid event = Factory.create(:actual_event, :type => type)
    assert_equal type, event.type
  end

  should "support the ccom object with events it is for" do
    h = Factory.create(:asset_on_segment_history)
    assert_valid event = Factory.create(:actual_event, :hist => h)
    assert_equal h, event.hist
  end

  context "with an asset and a history" do
    setup do
      assert @asset = Factory.create(:asset)
      assert @segment = Factory.create(:segment, :tag => "segment")
      assert @hist = Factory.create(:asset_on_segment_history, :segment => @segment)
    end

    context "for an install event" do
      setup do
        assert @event = ActualEvent.create(:monitored_object => @asset, :hist => @hist, :type => Type.install_event)
      end

      should "have the asset's user tag in the event's user tag" do
        assert_match @asset.tag, @event.tag
      end

      should "have the segment's user tag in the event's user tag" do
        assert_match @segment.tag, @event.tag
      end

      should "have the object type in the event's tag" do
        assert_match @event.type.tag, @event.tag
      end
    end
  end

  should "not blow up" do
    h = AssetOnSegmentHistory.new(:g_u_i_d => "745b3eae-9ebd-46fa-a239-2436a4e67d00")
    s = Segment.new(:g_u_i_d => "515b3eae-93bf-44da-a239-2436ece17deb")
    a = Asset.new(:g_u_i_d => "df3cb180-e410-11de-8a39-0800200c9a66", :segment => s)
    assert_kind_of ActualEvent, ActualEvent.create(:monitored_object => a, :hist => h, :type => Type.remove_event)
  end

  should "support a monitored object" do
    asset = Factory.create(:asset)
    assert_valid event = Factory.create(:actual_event, :monitored_object => asset)
    assert_equal asset, event.monitored_object
  end

  context "generating xml" do
    setup do
      @asset = Factory.create(:asset)
      @segment = Factory.create(:segment)
      @hist = Factory.create(:asset_on_segment_history, :segment => @segment)
      @type = Factory.create(:type, :name => "Install Event")
      @event = Factory.create(:actual_event, :type => @type, :hist => @hist, :monitored_object => @asset)
      @xml = @event.to_xml
      @doc = Nokogiri::XML.parse(@xml)
    end
    
    should "have the proper root path" do
      assert_has_xpath("/CCOMData/Entity[@*='ActualEvent']", @doc)
    end

    should "specify the object type" do
      assert_has_xpath("//Entity[@*='ActualEvent']/Type", @doc)
    end

    context "the for ccom object with events" do
      setup do
        @subdoc_list = @doc.mimosa_xpath("//Entity/EventableEntity")
        @element = @subdoc_list.first
      end

      should "have a single element" do
        assert_equal 1, @subdoc_list.size
      end

      should "have the guid for the installed on segment" do
        assert_equal @segment.g_u_i_d, @element.mimosa_xpath("//EventableEntity/GUID").first.content
      end

      should "have the proper namespace and type" do
        assert_not_nil type_attr = @element.attribute_with_ns("type", XSI_XMLNS).value
        assert_equal "Segment", type_attr, @element.to_s
      end
    end

    context "the monitored object" do
      setup do
        RAILS_DEFAULT_LOGGER.debug("***#{@doc}")
        @subdoc_list = @doc.mimosa_xpath("//Entity/AssetOnSegmentHistory/Asset")
        @element = @subdoc_list.first
      end

      should "have a single element" do
        assert_equal 1, @subdoc_list.size
      end

      should "have the guid for the asset" do
        assert_equal @asset.g_u_i_d, @element.mimosa_xpath("//Asset/GUID").first.content, @element.to_s
      end
    end

  end
end
