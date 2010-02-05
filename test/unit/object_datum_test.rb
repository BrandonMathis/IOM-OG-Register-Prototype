require 'test_helper'

class ObjectDatumTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:object_datum)
  end

  should "allow eng unit type" do
    assert_valid Factory.create(:object_datum, :eng_unit_type => Factory.create(:eng_unit_type))
  end

  context "generating xml" do
    setup do
      @datum = Factory.create(:object_datum, :eng_unit_type => Factory.create(:eng_unit_type))

      builder = Builder::XmlMarkup.new
      @xsi = "somthine"
      @xml = builder.tag!("ObjectDatum", "xmlns:xsi" => @xsi) do |b|
        @datum.build_xml(b)
      end
      @doc = Nokogiri::XML.parse(@xml)
    end
    
    should "have proper path for data value" do
      assert_not_nil data_node = @doc.xpath("//ObjectDatum/hasData/TextType").first
      assert_equal @datum.data, data_node.content
    end

    should "have the proper path for attribute type" do
      assert_not_nil attribute_type_node = @doc.xpath("//ObjectDatum/hasAttributeType").first
    end

    should "have the proper path for eng unit type" do
      assert_not_nil attribute_type_node = @doc.xpath("//ObjectDatum/hasEngUnitType").first
    end
  end
end
