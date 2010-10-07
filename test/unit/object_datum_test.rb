require 'test_helper'

class ObjectDatumTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:object_datum)
  end

  should "allow eng unit type" do
    eng_type = Factory.create(:eng_unit_type)
    assert_valid datum = Factory.create(:object_datum, :eng_unit_type => eng_type)
    assert_equal eng_type, datum.eng_unit_type
  end

  should "allow attr type" do
    attr_type = Factory.create(:object_type)
    assert_valid datum = Factory.create(:object_datum, :object_type => attr_type)
    assert_equal attr_type, datum.object_type
  end

  context "generating xml" do
    setup do
      @type = Factory.create(:object_type)
      @datum = Factory.create(:object_datum, :eng_unit_type => Factory.create(:eng_unit_type), :object_type => @type)

      @doc = Nokogiri::XML.parse(@datum.to_xml)
    end
    
    should "have proper path for data value" do
      assert_not_nil data_node = @doc.mimosa_xpath("//Entity[@*='ObjectDatum']/Value/Text").first
      assert_equal @datum.data, data_node.content
    end

    should "have the proper path for attribute type" do
      assert_not_nil attribute_type_node = @doc.mimosa_xpath("//Entity[@*='ObjectDatum']/Type").first
    end

    should "have the proper path for eng unit type" do
      assert_not_nil attribute_type_node = @doc.mimosa_xpath("//Entity[@*='ObjectDatum']/UnitType").first
    end
  end
end
