require 'test_helper'

class NetworkConnectionTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:network_connection)
  end

  should "have a segment as a source" do
    assert_valid Factory.create(:network_connection, :source => Factory.create(:segment))
  end

  should "have a segment as a target" do
    assert_valid Factory.create(:network_connection, :target => Factory.create(:segment))
  end

  context "creating a network connection with a source segment" do
    setup do
      @segment_tag = "My happy segment"
      @network_connection = Factory.create(:network_connection,
                                           :source => Factory.create(:segment, :tag => @segment_tag))
      @guid = @network_connection.source.g_u_i_d
    end
    should "be able to find the embedded segment" do
      assert_equal @segment_tag, Segment.first(:conditions => { :g_u_i_d => @guid }).tag
    end
  end

  context "generating xml" do
    setup do
      @network_connection = Factory.create(:network_connection, 
                                           :source => Factory.create(:segment),
                                           :target => Factory.create(:segment))
      builder = Builder::XmlMarkup.new
      @xsi = "somthine"
      @xml = builder.tag!("NetworkConnection", "xmlns:xsi" => @xsi) do |b|
        @network_connection.build_xml(b)
      end
      @doc = Nokogiri::XML.parse(@xml)
    end
    
    should "have proper namespace and type for source element" do
      assert_not_nil source = @doc.xpath("//NetworkConnection/FromEntity").first
      assert_not_nil target = @doc.xpath("//NetworkConnection/ToEntity").first
      assert_not_nil type_attr = source.attribute_with_ns("type", @xsi).value
      assert_equal "Segment", type_attr, source.inspect
      assert_equal "Segment", type_attr, target.inspect
    end
  end
end
