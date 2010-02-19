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

  should "have an install_asset_id accessor that doesn't blow up" do
    assert_nil Factory.create(:segment).install_asset_id
  end

  context "with an asset and a segment" do
    setup do
      @asset = Factory.create(:asset)
      @segment = Factory.create(:segment)
    end

    context "installing the asset via the segment's setter" do
      setup do
        @segment.update_attributes(:install_asset_id => @asset.guid)
      end

      before_should "fire off the install event" do
        flexmock(AssetObserver).should_receive(:install).with(@asset, @segment).once
      end
      
      should "include the asset in the segment's list of installed assets" do
        assert @segment.installed_assets.include?(@asset)
      end

      should "have the segment as the asset's (installed on) segment" do
        assert_equal @segment, Asset.find_by_guid(@asset.guid).segment
      end

      context "and uninstalling assets" do
        setup do
          @segment.update_attributes(:delete_asset_id => @asset.guid)
          @segment = Segment.find_by_guid(@segment.guid)
        end

        before_should "fire off the uninstall event" do
          flexmock(AssetObserver).should_receive(:remove).with(@asset, @segment).once
        end
        
        should "not include the asset in the segment's list of installed assets" do
          assert ! @segment.installed_assets.include?(@asset)
        end

        should "have nil as the asset's (installed on) segment" do
          assert_nil Asset.find_by_guid(@asset.guid).segment
        end
      end

    end
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
