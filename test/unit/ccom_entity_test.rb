require 'test_helper'

class CcomEntityTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:ccom_entity)
  end

  context "to xml" do
    setup do
      @ccom_entity = Factory.create(:ccom_entity, 
                                    :id_in_source => "0000000000000000.1.125",
                                    :source_id => "www.mimosa.org/CRIS/V3-2-1/meas_loc_type",
                                    :user_name => "Vibration, Absolute, Casing, Broadband")
      @xml = @ccom_entity.to_xml
      @doc = Nokogiri::XML.parse(@xml)
    end

    should "generate the proper root node" do
      assert_equal "CCOMData", @doc.root.name
    end

    should "include id in source" do
      xpath = "/CCOMData/CCOMEntity/idInSource"
      node_set = @doc.xpath(xpath.to_mimosa, mimosa_xmlns)
      assert_not_nil node_set.first, "#{xpath}\n#{@xml.inspect}\n#{@doc.inspect}"
#      assert_equal @ccom_entity.id_in_source, 
    end

    should "not include status code when it's blank" do
      node_set = @doc.xpath("//CCOMEntity/statusCode", mimosa_xmlns)
      assert node_set.blank?, node_set.inspect
    end
  end
end
