require 'test_helper'

class MeasLocationTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:meas_location)
  end

  should "support object type" do
    assert_valid Factory.create(:meas_location, :object_type => Factory.create(:object_type))
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
                                      :object_type => Factory.create(:object_type),
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
  
  context "duplicating the entity" do
    setup do
      @eng_unit = Factory.create(:eng_unit_type)
      @obj_data = Factory.create(:object_datum)
      @meas_loc1 = Factory.create(:meas_location, :default_eng_unit_type => @eng_unit, :object_data => @obj_data)
      @meas_loc2 = @meas_loc1.dup_entity()
    end
    should "create two separate objects" do
      assert_not_equal @meas_loc1, @meas_loc2
      assert_equal @meas_loc1.guid, @meas_loc2.guid
    end
    should "copy all attributes" do
      @meas_loc1.field_names.each do |field|
        if @meas_loc1.editable_attribute_names.include?(field)
          assert_equal @meas_loc1.send("#{field}"), @meas_loc2.send("#{field}")
        end
      end
    end
    should "copy the default engineering unit type" do
      @meas_loc1.default_eng_unit_type.field_names.each do |field|
        if @meas_loc1.editable_attribute_names.include?(field)
          assert_equal @meas_loc1.default_eng_unit_type.send("#{field}"), @meas_loc2.default_eng_unit_type.send("#{field}")
        end
      end
    end
    should "copy the object data" do
      @meas_loc1.object_data.first.field_names.each do |field|
        if @meas_loc1.editable_attribute_names.include?(field)
          assert_equal @meas_loc1.object_data.first.send("#{field}"), @meas_loc2.object_data.first.send("#{field}")
        end
      end
    end
    context "with new guids" do
      setup do
        @meas_loc2 = @meas_loc1.dup_entity(:gen_new_guids => true)
      end
      should "generate new guids for the two meas locations" do
        assert_not_equal @meas_loc1, @meas_loc2
      end
      should "not generate new guids for default engineering unit types" do
        assert_equal @meas_loc1.default_eng_unit_type.guid, @meas_loc2.default_eng_unit_type.guid
      end
      should "generate new guids for object data" do
        assert_not_equal @meas_loc1.object_data.first.guid, @meas_loc2.object_data.first.guid
      end
    end
  end
end
