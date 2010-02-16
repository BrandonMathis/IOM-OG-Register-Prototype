require 'test_helper'

class NetworkConnectionTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:network_connection)
  end

  should "have a segment as a source" do
    assert_valid Factory.create(:network_connection, :source => Factory.create(:segment))
  end

  should "have many targets as network connections" do
    target = Factory.create(:network_connection)
    assert_valid network_connection = Factory.create(:network_connection, :targets => [target])
    assert network_connection.targets.include?(target)
  end

  context "creating a network connection with a source segment" do
    setup do
      @segment_tag = "My happy segment"
      @network_connection = Factory.create(:network_connection,
                                           :source => Factory.create(:segment, :user_tag => @segment_tag))
      @guid = @network_connection.source.guid
    end
    should "be able to find the embedded segment" do
      assert_equal @segment_tag, Segment.first(:conditions => { :guid => @guid }).user_tag
    end
  end

  context "generating xml" do
    setup do
      @network_connection = Factory.create(:network_connection, 
                                           :source => Factory.create(:segment))
      builder = Builder::XmlMarkup.new
      @xsi = "somthine"
      @xml = builder.tag!("NetworkConnection", "xmlns:xsi" => @xsi) do |b|
        @network_connection.build_xml(b)
      end
      @doc = Nokogiri::XML.parse(@xml)
    end
    
    should "have proper namespace and type for source element" do
      assert_not_nil source = @doc.xpath("//NetworkConnection/source").first
      assert_not_nil type_attr = source.attribute_with_ns("type", @xsi).value
      assert_equal "Segment", type_attr, source.inspect
    end
  end
end
