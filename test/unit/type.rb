require 'test_helper'

class Type < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:object_type)
  end

  should "support an info collection" do
    info_collection = Factory.create(:info_collection)
    assert_valid object_type = Factory.create(:object_type, :info_collection => info_collection)
    assert_equal info_collection, object_type.info_collection
  end

  context "with the one and only install event object type" do
    setup do
      @install_event = Type.install_event
    end
    should "have user name" do
      assert_equal "Install Event", @install_event.name
    end
  end

  context "generating xml" do
    setup do
      @object_type = Factory.create(:object_type, 
                                    :i_d_in_info_source => "0000000000000000.1.125",
                                    :source_id => "www.mimosa.org/CRIS/V3-2-1/meas_loc_type",
                                    :name => "Vibration, Absolute, Casing, Broadband")
      builder = Builder::XmlMarkup.new
      xml = builder.Type do |b|
        @object_type.build_xml(b)
      end
      @doc = Nokogiri::XML.parse(xml)
    end
    
    should "include id in source" do
      assert_equal @object_type.i_d_in_info_source, @doc.xpath("//Type/IDInInfoSource").first.content
    end
  end
end
