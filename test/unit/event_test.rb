require 'test_helper'

class EventTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:event)
  end

  should "support assigning an object type" do
    object_type = Factory.create(:object_type, :user_name => "Install Event")
    assert_valid event = Factory.create(:event, :object_type => object_type)
    assert_equal object_type, event.object_type
  end

  should "support the ccom object with events it is for" do
    segment = Factory.create(:segment)
    assert_valid event = Factory.create(:event, :for => segment)
    assert_equal segment, event.for
  end

  context "with an asset and a segment" do
    setup do
      assert @asset = Factory.create(:asset)
      assert @segment = Factory.create(:segment, :user_tag => "segment")
    end

    context "for an install event" do
      setup do
        assert @event = Event.create(:monitored_object => @asset, :for => @segment, :object_type => ObjectType.install_event)
      end

      should "have the asset's user tag in the event's user tag" do
        assert_match @asset.user_tag, @event.user_tag
      end

      should "have the segment's user tag in the event's user tag" do
        assert_match @segment.user_tag, @event.user_tag
      end

      should "have the object type in the event's tag" do
        assert_match @event.object_type.user_tag, @event.user_tag
      end
    end
  end

  should "not blow up" do
    s = Segment.new(:guid => "515b3eae-93bf-44da-a239-2436ece17deb")
    a = Asset.new(:guid => "df3cb180-e410-11de-8a39-0800200c9a66", :installed_on_segment => s)
    assert_kind_of Event, Event.create(:monitored_object => a, :for => s, :object_type => ObjectType.remove_event)
  end

  should "support a monitored object" do
    asset = Factory.create(:asset)
    assert_valid event = Factory.create(:event, :monitored_object => asset)
    assert_equal asset, event.monitored_object
  end

  context "generating xml" do
    setup do
      @asset = Factory.create(:asset)
      @segment = Factory.create(:segment)
      @object_type = Factory.create(:object_type, :user_name => "Install Event")
      @event = Factory.create(:event, :object_type => @object_type, :for => @segment, :monitored_object => @asset)
      @xml = @event.to_xml
      @doc = Nokogiri::XML.parse(@xml)
    end
    
    should "have the proper root path" do
      assert_has_xpath("/CCOMData/Event", @doc)
    end

    should "specify the object type" do
      assert_has_xpath("//Event/ofObjectType", @doc)
    end

    context "the for ccom object with events" do
      setup do
        @subdoc_list = @doc.mimosa_xpath("//Event/forCCOMObjectWithEvents")
        @element = @subdoc_list.first
      end

      should "have a single element" do
        assert_equal 1, @subdoc_list.size
      end

      should "have the guid for the installed on segment" do
        assert_equal @segment.guid, @element.mimosa_xpath("//forCCOMObjectWithEvents/guid").first.content
      end

      should "have the proper namespace and type" do
        assert_not_nil type_attr = @element.attribute_with_ns("type", XSI_XMLNS).value
        assert_equal "Segment", type_attr, @element.to_s
      end
    end

    context "the monitored object" do
      setup do
        @subdoc_list = @doc.mimosa_xpath("//Event/hasMonitoredObject")
        @element = @subdoc_list.first
      end

      should "have a single element" do
        assert_equal 1, @subdoc_list.size
      end

      should "have the guid for the asset" do
        assert_equal @asset.guid, @element.mimosa_xpath("//hasMonitoredObject/guid").first.content, @element.to_s
      end

      should "have the proper namespace and type" do
        assert_not_nil type_attr = @element.attribute_with_ns("type", XSI_XMLNS).value
        assert_equal "Asset", type_attr, @element.to_s
      end
    end

  end
end
