require 'test_helper'

class MeasLocationTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:meas_location)
  end

  should "support object type" do
    assert_valid Factory.create(:meas_location, :type => Factory.create(:type))
  end

  should "support default engineering unit type" do
    assert_valid Factory.create(:meas_location, :default_eng_unit_type => Factory.create(:eng_unit_type))
  end

  should "support multiple object data" do
    assert_valid Factory.create(:meas_location,
                                :object_data => [Factory.create(:object_datum), Factory.create(:object_datum)])
  end

  context "generating xml" do
    setup do
      
      @meas_location = Factory.create(:meas_location,
                                      :object_data => [Factory.create(:object_datum), Factory.create(:object_datum)])
      builder = Builder::XmlMarkup.new
      @xsi = "somthine"
      @xml = builder.tag!("MeasLocation", "xmlns:xsi" => @xsi) do |b|
        @meas_location.build_xml(b)
      end
      @doc = Nokogiri::XML.parse(@xml)
    end
    
    should "have proper attribute name for object type" do
      assert_not_nil object_type = @doc.xpath("//MeasLocation/Type").first, "no Type"
      assert_not_nil object_user_name = object_type.xpath("//Type/Name").first, "object type has no Name, #{object_type.inspect}"
      assert_equal @meas_location.object_type.name, object_user_name.content
    end

    should "have proper number of object data elements" do
      assert_equal @meas_location.object_data.size, @doc.xpath("//MeasLocation/Attribute").size
    end

    should "have a default eng unit" do
      assert_not_nil @doc.xpath("//MeasLocation/DefaultUnitType").first
    end
  end

end
