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
      assert @doc.mimosa_xpath("//ValidNetwork").empty?
    end

    should "have proper number of meas location elements" do
      assert_equal @segment.meas_locations.size, @doc.mimosa_xpath("//Segment/MeasurementLocation").size
    end
  end

  context "generating xml for a segment with a segment config network" do
    setup do
      @segment = Factory.create(:segment,
                                :segment_config_network => SegmentConfigNetwork.create)
      @doc = Nokogiri::XML.parse(@segment.to_xml)
    end

    should "have an element for the scn association" do
      assert ! @doc.mimosa_xpath("//ValidNetwork").empty?
    end
    
 end

  context "xml for fields" do
    setup do

    end
  end
  context "generating xml for a segment with an installed asset" do
    setup do
      @asset = Factory.create(:asset)
      @asset_on_segment_history = Factory.create(:asset_on_segment_history)
      @asset.asset_on_segment_history = @asset_on_segment_history
      @asset.save
      @asset_on_segment_history = AssetOnSegmentHistory.find_by_guid(@asset_on_segment_history.g_u_i_d)
      @doc = Nokogiri::XML.parse(@asset.to_xml)
    end

    should "not blow up" do
      assert true
    end

    should "not have an xml element for the segment foreign key" do
      assert @doc.mimosa_xpath("//assetOnSegmentHistoryId").empty?, @asset.to_xml
    end

  end
end
