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
      path = "/CCOMData/Event"
      assert_not_nil @doc.xpath(path.to_mimosa, mimosa_xmlns).first, "#{path}\n#{@xml.inspect}"
    end

  end
end
