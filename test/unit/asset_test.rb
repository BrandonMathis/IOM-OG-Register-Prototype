require 'test_helper'

class AssetTest < ActiveSupport::TestCase
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

  should "support an installed on segment" do
    segment = Factory.create(:segment)
    assert_valid asset = Factory.create(:asset)
    asset.installed_on_segment = segment
    assert asset.save
    assert_equal segment, asset.installed_on_segment
  end
end
