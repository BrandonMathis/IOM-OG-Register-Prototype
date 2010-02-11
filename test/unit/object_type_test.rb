require 'test_helper'

class ObjectTypeTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:object_type)
  end

  should "support an info collection" do
    info_collection = Factory.create(:info_collection)
    assert_valid object_type = Factory.create(:object_type, :info_collection => info_collection)
    assert_equal info_collection, object_type.info_collection
  end

  context "generating xml" do
    setup do
      @object_type = Factory.create(:object_type, 
                                    :id_in_source => "0000000000000000.1.125",
                                    :source_id => "www.mimosa.org/CRIS/V3-2-1/meas_loc_type",
                                    :user_name => "Vibration, Absolute, Casing, Broadband")
      builder = Builder::XmlMarkup.new
      xml = builder.ObjectType do |b|
        @object_type.build_xml(b)
      end
      @doc = Nokogiri::XML.parse(xml)
    end
    
    should "include id in source" do
      assert_equal @object_type.id_in_source, @doc.xpath("//ObjectType/idInSource").first.content
    end
  end
end
