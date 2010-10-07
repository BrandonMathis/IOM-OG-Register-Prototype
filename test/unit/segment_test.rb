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
      assert @seg.installed_assets.include?(@asset) && @seg.installed_assets.include?(asset2)
    end
  end
  
  context "The segment" do
    setup do
      @seg = Factory.create(:segment)
    end
    should "be valid from factory" do
      assert_valid Factory.create(:segment)
    end
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
        asset = Asset.find_by_guid(@asset.g_u_i_d)
        @hist_guid = asset.asset_on_segment_history.g_u_i_d
        @hist = asset.asset_on_segment_history
      end
      
      should "not generate a remove event" do
        assert flexmock(AssetObserver).should_receive(:remove).with(@asset, @hist).never
      end
      
      should "generate an asset install history with GUID" do
        assert_not_nil @hist.g_u_i_d
      end
      
      should "generate an asset install history start timestamp" do
        assert @hist.start
      end
      
      should "generate an asset install history with a referenceable segment" do
        assert_not_nil @hist.segment
        assert_equal @hist.segment.g_u_i_d, @segment.g_u_i_d
      end

      before_should "fire off the install event" do
        flexmock(AssetObserver).should_receive(:install).once
      end
      
      should "include the asset in the segment's list of installed assets" do
        assert @segment.installed_assets.include?(@asset)
      end

      should "have the segment as the asset's (installed on) segment" do
        assert_equal @segment, Asset.find_by_guid(@asset.g_u_i_d).segment
      end
      
      context "then generating the xml of that logged history" do
        setup do
          builder = Builder::XmlMarkup.new
          @xml = @hist.to_xml
          @doc = Nokogiri::XML.parse(@xml)
        end
        
        should "contain a copy of Asset with a valid GUID" do
          assert_has_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']", @doc)
          assert_has_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Asset", @doc)
          assert_equal @asset.g_u_i_d, @doc.mimosa_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Asset/GUID").first.content
          assert_equal @asset.tag, @doc.mimosa_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Asset/Tag").first.content
        end
        
        should "contain a copy of the Segment with a valid GUID" do
          assert_has_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']", @doc)
          assert_has_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Segment", @doc)
          assert_equal @segment.g_u_i_d, @doc.mimosa_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Segment/GUID").first.content
          assert_equal @asset.tag, @doc.mimosa_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Asset/Tag").first.content
        end
      end   
      
      context "and uninstalling assets" do
        setup do
          @segment.update_attributes(:delete_asset_id => @asset.g_u_i_d)
          @segment = Segment.find_by_guid(@segment.g_u_i_d)
          @asset = Asset.find_by_guid(@asset.g_u_i_d)
          @hist = AssetOnSegmentHistory.find_by_guid(@hist_guid)
        end

        before_should "fire off the uninstall event" do
          flexmock(AssetObserver).should_receive(:remove).with(@asset, @hist).once
        end
        
        should "have nil as the assets AOSH" do
          assert_nil @asset.asset_on_segment_history_id
        end
        
        should "set an end time for the asset on segment history" do
          assert_not_nil @hist.end
        end
        
        should "not include the asset in the segment's list of installed assets" do
          assert ! @segment.installed_assets.include?(@asset)
        end

        should "have nil as the asset's on segment history" do
          hist = Asset.find_by_guid(@asset.g_u_i_d).asset_on_segment_history_id
          assert_nil hist
        end
        
        should "keep a history of that asset being installed then uninstalled" do
          assert_not_nil @hist.logged_asset
          assert_equal @hist.logged_asset.g_u_i_d, @asset.g_u_i_d
          @asset.attribute_names.each do |field|
            unless (value = @asset.send(field)).blank?
              unless (value2 = @hist.logged_asset.send(field)).blank?
                assert_equal value, value2 unless field == :last_edited
              end
            end
          end 
        end
        context "then generating the xml of that logged history" do
          setup do
            builder = Builder::XmlMarkup.new
            @xml = @hist.to_xml
            @doc = Nokogiri::XML.parse(@xml)
          end
          should "contain a copy of Asset with a valid GUID" do
            assert_has_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']", @doc)
            assert_has_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Asset", @doc)
            assert_equal @asset.g_u_i_d, @doc.mimosa_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Asset/GUID").first.content
            assert_equal @asset.tag, @doc.mimosa_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Asset/Tag").first.content
          end

          should "contain a copy of the Segment with a valid GUID" do
            assert_has_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']", @doc)
            assert_has_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Segment", @doc)
            assert_equal @segment.g_u_i_d, @doc.mimosa_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Segment/GUID").first.content
            assert_equal @asset.tag, @doc.mimosa_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Asset/Tag").first.content
          end
        end
          
        context "Then reinstalling the asset" do
          setup do
            @segment.update_attributes(:install_asset_id => @asset.g_u_i_d)
          end
          should "not generate a remove event" do
            assert flexmock(AssetObserver).should_receive(:remove).with(@asset, @hist).never
          end
          should "include the reinstalled asset in the list of installed assets" do
            assert @segment.installed_assets.include?(@asset)
          end
          should "keep a logged copy of that asset in the history" do
            assert_equal @hist.logged_asset.g_u_i_d, @asset.g_u_i_d
          end
          context "then generating the xml of that logged history" do
            setup do
              builder = Builder::XmlMarkup.new
              @xml = @hist.to_xml
              @doc = Nokogiri::XML.parse(@xml)
            end

            should "contain a copy of Asset with a valid GUID" do
              assert_has_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']", @doc)
              assert_has_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Asset", @doc)
              assert_equal @asset.g_u_i_d, @doc.mimosa_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Asset/GUID").first.content
              assert_equal @asset.tag, @doc.mimosa_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Asset/Tag").first.content
            end

            should "contain a copy of the Segment with a valid GUID" do
              assert_has_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']", @doc)
              assert_has_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Segment", @doc)
              assert_equal @segment.g_u_i_d, @doc.mimosa_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Segment/GUID").first.content
              assert_equal @segment.tag, @doc.mimosa_xpath("/CCOMData/Entity[@*='AssetOnSegmentHistory']/Segment/Tag").first.content
            end
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
end
