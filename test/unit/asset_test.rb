require 'test_helper'

class AssetTest < ActiveSupport::TestCase
  context "The Asset" do
    setup do
      @asset = Factory.create(:asset)
    end
    
    should "be valid from factory" do
      assert_valid @asset
    end
    
    should "have a valid guid" do
      assert Asset.valid_guid(@asset.g_u_i_d)
    end
    
    should "have a last edited time" do
      assert_not_nil @asset.last_edited
    end
  end
  
  should "support a serial number" do
    sn = "3Z84G32AA0-4"
    assert_valid asset = Factory.create(:asset, :serial_number => sn)
    assert_equal sn, asset.serial_number
  end

  should "support a manufacturer" do
    manufacturer = Factory.create(:manufacturer)
    assert_valid asset = Factory.create(:asset, :manufacturer => manufacturer)
    assert_equal manufacturer, asset.manufacturer
  end

  should "support a model" do
    model = Factory.create(:model)
    assert_valid asset = Factory.create(:asset, :model => model)
    assert_equal model, asset.model
  end

  should "support an asset config network" do
    valid_network = Factory.create(:valid_network)
    assert_valid asset = Factory.create(:asset, :valid_network => valid_network)
    assert_equal valid_network, asset.valid_network
  end

  
  context "uninstalled assets" do
    setup do
      @segment = Factory.create(:segment)
      @hist = Factory.create(:asset_on_segment_history)
      @installed_asset = Factory.create(:asset, :asset_on_segment_history => @hist)
      @uninstalled_asset = Factory.create(:asset)
      @uninstalled_assets = Asset.uninstalled
    end

    should "not include the installed asset" do
      assert ! @uninstalled_assets.include?(@installed_asset)
    end

    should "include the uninstalled asset" do
      assert @uninstalled_assets.include?(@uninstalled_asset)
    end
  end

  context "creating an asset install history" do
    setup do
      @hist = Factory.create(:asset_on_segment_history)
      @asset = Factory.create(:asset, :asset_on_segment_history => @hist)
    end
    
    should "have the asset installed on the segment" do
      assert_equal @hist, @asset.asset_on_segment_history
    end

    should "have the asset in the list of installed assets on the segment" do
      assert @hist.assets.include?(@asset)
    end
  end

  context "observing segment changes" do
    context "with an asset" do
      setup do
        @asset = Factory.create(:asset)
        @hist = Factory.create(:asset_on_segment_history)
      end

      should "fire an install event when the segment is assigned" do
        flexmock(AssetObserver).should_receive(:install).with(@asset, @hist).once
        @asset.asset_on_segment_history = @hist
        assert @asset.save
      end
    end

    context "with an asset already installed on segment" do
      setup do
        assert @asset_on_segment_history = Factory.create(:asset_on_segment_history)
        @asset = Factory.create(:asset, :asset_on_segment_history => @asset_on_segment_history)
      end

      should "fire a remove event when the segment is set to nil" do
        flexmock(AssetObserver).should_receive(:remove).once
        @asset.asset_on_segment_history = nil
        assert @asset.save
        assert_nil @asset.asset_on_segment_history
      end

      should "fire both a remove and an install event when changing the asset on segment history" do
        @new_hist = Factory.create(:asset_on_segment_history)
        flexmock(AssetObserver).should_receive(:install).with(@asset, @new_hist).once
        flexmock(AssetObserver).should_receive(:remove).with(@asset, @asset_on_segment_history).once
        @asset.asset_on_segment_history = @new_hist
        assert @asset.save
      end
    end
  end

  context "assigning to entry points" do
    setup do
      @entry_edge = Factory.create(:network_connection)
      @asset = Factory.create(:asset, :entry_edges => @entry_edge)
    end
    should "be assigned" do
      assert_equal [@entry_edge], @asset.entry_edges
    end
    should "still be assinged when I reload it" do
      assert_equal [@entry_edge], Asset.find_by_guid(@asset.g_u_i_d).entry_edges
    end
  end

  context "importing xml" do
    setup do
      @serial_number = "12341234123412341"
      @asset = Factory.create(:asset, :serial_number => @serial_number)
      @asset.g_u_i_d = UUID.generate
      @xml = @asset.to_xml
      @parsed_asset = Asset.from_xml(@xml)
    end
    should "parse the serial number too" do
      assert_equal @serial_number, @parsed_asset.serial_number
    end
  end

  context "generating xml" do
    setup do
      @asset = Factory.create(:asset)
      @doc = Nokogiri::XML.parse(@asset.to_xml)
    end

    should "have the proper element name" do
      assert_has_xpath("/CCOMData/Entity[@*='Asset']", @doc)
    end
  end

  context "with both topology asset and serialized asset" do
    setup do
      @topology = Factory.create(:topology_asset)
      @asset = Factory.create(:serialized_asset)
    end

    context "finding serialized assets" do
      setup { @assets = Asset.serialized.all }
      should "not contain the topology" do
        assert ! @assets.include?(@topology)
      end
      should "contain the serialized asset" do
        assert @assets.include?(@asset)
      end
    end

    context "finding topologies" do
      setup do
        @topologies = Asset.topologies.all
      end
      should "not contain the serialized asset" do
        assert ! @topologies.include?(@asset)
      end
      should "contain the topology" do
        assert @topologies.include?(@topology)
      end
    end
  end
end
