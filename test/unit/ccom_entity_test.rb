require 'test_helper'

class CcomEntityTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:ccom_entity)
  end

  context "generating xml" do
    setup do
      @ccom_entity = Factory.create(:ccom_entity, 
                                    :id_in_source => "0000000000000000.1.125",
                                    :source_id => "www.mimosa.org/CRIS/V3-2-1/meas_loc_type",
                                    :user_name => "Vibration, Absolute, Casing, Broadband")
      builder = Builder::XmlMarkup.new
      xml = builder.CCOMEntity do |b|
        @ccom_entity.build_xml(b)
      end
      @doc = Nokogiri::XML.parse(xml)
    end
    
    should "include id in source" do
      assert_equal @ccom_entity.id_in_source, @doc.xpath("//CCOMEntity/idInSource").first.content
    end

    should "not include status code when it's blank" do
      node_set = @doc.xpath("//CCOMEntity/statusCode")
      assert node_set.blank?, node_set.inspect
    end
  end
end
