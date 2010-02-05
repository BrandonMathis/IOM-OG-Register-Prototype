require 'test_helper'

class SegmentTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:segment)
  end

  should "support multiple meas locations" do
    assert_valid Factory.create(:segment,
                                :meas_locations => [Factory.create(:meas_location), 
                                                    Factory.create(:meas_location)])
  end

  context "generating xml" do
    setup do
      @segment = Factory.create(:segment,
                                :meas_locations => [Factory.create(:meas_location), 
                                                    Factory.create(:meas_location)])

      builder = Builder::XmlMarkup.new
      @xsi = "somthine"
      @xml = builder.tag!("Segment", "xmlns:xsi" => @xsi) do |b|
        @segment.build_xml(b)
      end
      @doc = Nokogiri::XML.parse(@xml)
    end
    
    should "have proper number of meas location elements" do
      assert_equal @segment.meas_locations.size, @doc.xpath("//Segment/hasMeasLocation").size
    end
  end
end
