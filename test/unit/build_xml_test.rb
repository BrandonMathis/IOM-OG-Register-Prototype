require 'test_helper'

class BuildXmlTest < ActiveSupport::TestCase
  context "generating xml for a segment and a couple of meas locations" do
    setup do
      @segment = Factory.create(:segment,
                                :meas_locations => [Factory.create(:meas_location), 
                                                    Factory.create(:meas_location)])
      @doc = Nokogiri::XML.parse(@segment.to_xml)
    end
    
    should "not have an empty segment config network element" do
      assert @doc.mimosa_xpath("//hasSegmentConfigNetwork").empty?
    end

    should "have proper number of meas location elements" do
      assert_equal @segment.meas_locations.size, @doc.mimosa_xpath("//Segment/hasMeasLocation").size
    end
  end

  context "generating xml for a segment with a segment config network" do
    setup do
      @segment = Factory.create(:segment,
                                :segment_config_network => SegmentConfigNetwork.create)
      @doc = Nokogiri::XML.parse(@segment.to_xml)
    end

    should "have an element for the scn association" do
      assert ! @doc.mimosa_xpath("//hasSegmentConfigNetwork").empty?
    end
    
 end

  context "xml for fields" do
    setup do

    end
  end
  context "generating xml for a segment with an installed asset" do
    setup do
      @asset = Factory.create(:asset)
      @segment = Factory.create(:segment)
      @asset.segment = @segment
      @asset.save
      @segment = Segment.find_by_guid(@segment.guid)
      @doc = Nokogiri::XML.parse(@asset.to_xml)
    end

    should "not blow up" do
      assert true
    end

    should "not have an xml element for the segment foreign key" do
      assert @doc.mimosa_xpath("//segmentId").empty?, @asset.to_xml
    end

  end
end
