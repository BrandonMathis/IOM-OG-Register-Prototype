require 'test_helper'

class SegmentTest < ActiveSupport::TestCase
  context "method installed_assets" do
    setup do
      @asset = Factory.create(:asset)
      @seg = Factory.create(:segment)
    end
    should "contain occurance of asset that has been installed on the segment" do
      @seg.install_asset_id=(@asset.g_u_i_d)
      assert @seg.installed_assets.include?(@asset)
    end
    should "give an array of installed assets" do
      asset2 = Factory.create(:asset)
      @seg.install_asset_id=(asset2.g_u_i_d)
      @seg.install_asset_id=(@asset.g_u_i_d)
      assert @seg.installed_assets.include?(@asset)
      assert @seg.installed_assets.include?(asset2)
    end
  end

  should "be valid from factory" do
    assert_valid Factory.create(:segment)
  end

  should "support multiple meas locations" do
    assert_valid Factory.create(:segment,
                                :meas_locations => [Factory.create(:meas_location), 
                                                    Factory.create(:meas_location)])
  end

  should "support a segment config network" do
    scn = SegmentConfigNetwork.create
    assert_valid segment = Factory.create(:segment, :segment_config_network => scn)
    assert_equal scn, segment.segment_config_network
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
        @segment.update_attributes(:install_asset_id => @asset.g_u_i_d)
      end
      
      should "generate an asset install history start timestamp" do
        asset = Asset.find_by_guid(@asset.g_u_i_d)
        hist = asset.asset_on_segment_history
        assert Time.parse(hist.start) < Time.now
      end

      before_should "fire off the install event" do
        flexmock(AssetObserver).should_receive(:install).with(@asset, @segment).once
      end
      
      should "include the asset in the segment's list of installed assets" do
        assert @segment.installed_assets.include?(@asset)
      end

      should "have the segment as the asset's (installed on) segment" do
        assert_equal @segment, Asset.find_by_guid(@asset.g_u_i_d).segment
      end

      context "and uninstalling assets" do
        setup do
          @segment.update_attributes(:delete_asset_id => @asset.g_u_i_d)
          @segment = Segment.find_by_guid(@segment.g_u_i_d)
        end

        before_should "fire off the uninstall event" do
          flexmock(AssetObserver).should_receive(:remove).with(@asset, @segment).once
        end
        
        should "set an end time for the asset on segment history" do
          asset = Asset.find_by_guid(@asset.g_u_i_d)
          hist = asset.asset_on_segment_history
          assert_not_nil hist.end
        end
        
        should "not include the asset in the segment's list of installed assets" do
          assert ! @segment.installed_assets.include?(@asset)
        end

        should "have nil as the asset's on segment history" do
          asset = Asset.find_by_guid(@asset.g_u_i_d)
          RAILS_DEFAULT_LOGGER.debug("history #{asset.asset_on_segment_history}")
          assert asset.asset_on_segment_history == nil
        end
        context "Then reinstalling the asset" do
          setup do
            @segment.update_attributes(:install_asset_id => @asset.g_u_i_d)
          end
          should "include the reinstalled asset in the list of installed assets" do
            assert @segment.installed_assets.include?(@asset)
          end
        end          
      end

    end
  end

  context "installing assets" do
    setup do
      @asset = Factory.create(:asset)
      @segment = Factory.create(:segment)
      @hist = AssetOnSegmentHistory.create()
      @hist.install(@asset)
      @segment.asset_on_segment_historys << @hist
    end 
    
    should "list the asset as installed on the segment" do
      assert @segment.installed_assets.include?(@asset)
    end

    should "have the history as the asset's on segment history" do
      assert_equal @hist, @asset.asset_on_segment_history
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
      assert_equal @segment.meas_locations.size, @doc.xpath("//Segment/MeasurementLocation").size
    end
  end
  
  context "duplicating an asset" do
    setup do
      @asset = Factory.create(:asset)
      @asset2 = Asset.duplicate(@asset)
    end
    should "have the same guid" do
      asset_equal @asset.g_u_i_d, @asset2.g_u_i_d
    end
  end  
end
