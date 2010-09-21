require 'test_helper'

class AssetConfigNetworkTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:valid_network)
  end

  should "support an associated network" do
    assert_valid Factory.create(:valid_network, :network => Factory.create(:network))
  end

  # context "generating xml" do
  #   setup do
  #     @segment = Factory.create(:segment,
  #                               :meas_locations => [Factory.create(:meas_location), 
  #                                                   Factory.create(:meas_location)])

  #     builder = Builder::XmlMarkup.new
  #     @xsi = "somthine"
  #     @xml = builder.tag!("Segment", "xmlns:xsi" => @xsi) do |b|
  #       @segment.build_xml(b)
  #     end
  #     @doc = Nokogiri::XML.parse(@xml)
  #   end
    
  #   should "have proper number of meas location elements" do
  #     assert_equal @segment.meas_locations.size, @doc.xpath("//Segment/hasMeasLocation").size
  #   end
  # end
end
