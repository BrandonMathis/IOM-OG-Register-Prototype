require 'test_helper'

class AssetTest < ActiveSupport::TestCase

  def teardown
    super
    flexmock_teardown
  end
  
  should "be valid from factory" do
    assert_valid Factory.create(:asset)
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
    asset_config_network = Factory.create(:asset_config_network)
    assert_valid asset = Factory.create(:asset, :asset_config_network => asset_config_network)
    assert_equal asset_config_network, asset.asset_config_network
  end

  
  context "uninstalled assets" do
    setup do
      @segment = Factory.create(:segment)
      @installed_asset = Factory.create(:asset, :segment => @segment)
      @uninstalled_asset = Factory.create(:asset)
      @uninstalled_assets = Asset.uninstalled.all
    end

    should "not include the installed asset" do
      assert ! @uninstalled_assets.include?(@installed_asset)
    end

    should "include the uninstalled asset" do
      assert @uninstalled_assets.include?(@uninstalled_asset)
    end
  end

  context "creating an asset installed on a segment" do
    setup do
      @segment = Factory.create(:segment)
      @asset = Factory.create(:asset, :segment => @segment)
    end
    
    should "have the asset installed on the segment" do
      assert_equal @segment, @asset.segment
    end

    should "have the asset in the list of installed assets on the segment" do
      assert @segment.installed_assets.include?(@asset)
    end
  end

  context "observing segment changes" do
    context "with an asset" do
      setup do
        @asset = Factory.create(:asset)
        @segment = Factory.create(:segment)
      end

      should "fire an install event when the segment is assigned" do
        flexmock(AssetObserver).should_receive(:install).with(@asset, @segment).once
        @asset.segment = @segment
        assert @asset.save
      end
    end

    context "with an asset already installed on segment" do
      setup do
        assert @segment = Factory.create(:segment)
        @asset = Factory.create(:asset, :segment => @segment)
      end

      should "fire a remove event when the segment is set to nil" do
        flexmock(AssetObserver).should_receive(:remove).once
        @asset.segment = nil
        assert @asset.save
        assert_nil @asset.segment
      end

      should "fire both a remove and an install event when changing the segment" do
        @new_segment = Factory.create(:segment)
        flexmock(AssetObserver).should_receive(:install).with(@asset, @new_segment).once
        flexmock(AssetObserver).should_receive(:remove).with(@asset, @segment).once
        @asset.segment = @new_segment
        assert @asset.save
      end
    end
  end

  context "assigning to entry points" do
    setup do
      @entry_point = Factory.create(:network_connection)
      @asset = Factory.create(:asset, :entry_points => @entry_point)
    end
    should "be assigned" do
      assert_equal [@entry_point], @asset.entry_points
    end
    should "still be assinged when I reload it" do
      assert_equal [@entry_point], Asset.find_by_guid(@asset.guid).entry_points
    end
  end

  context "generating xml" do
    setup do
      @asset = Factory.create(:asset)
      @doc = Nokogiri::XML.parse(@asset.to_xml)
    end

    should "have the proper element name" do
      assert_has_xpath("/CCOMData/Asset", @doc)
    end
  end
end
