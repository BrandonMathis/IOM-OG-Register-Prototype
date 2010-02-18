require 'test_helper'

class SegmentTest < ActiveSupport::TestCase

  def teardown
    super
    flexmock_teardown
  end

  should "be valid from factory" do
    assert_valid Factory.create(:segment)
  end

  should "support multiple meas locations" do
    assert_valid Factory.create(:segment,
                                :meas_locations => [Factory.create(:meas_location), 
                                                    Factory.create(:meas_location)])
  end

  context "installing assets" do
    setup do
      @asset = Factory.create(:asset)
      @segment = Factory.create(:segment)
      @segment.installed_assets << @asset
    end

    should "list the asset as installed on the segment" do
      assert @segment.installed_assets.include?(@asset)
    end

    should "have the segment as the assets isntalled on location" do
      assert_equal @segment, @asset.segment
    end
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
