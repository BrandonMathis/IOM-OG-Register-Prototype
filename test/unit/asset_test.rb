require 'test_helper'

class AssetTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:asset)
  end

  should "support a serial number" do
    assert_valid Factory.create(:asset, :serial_number => "3Z84G32AA0-4")
  end

  should "support a manufacturer" do
    assert_valid Factory.create(:asset, :manufacturer => Factory.create(:manufacturer))
  end

  should "support a model" do
    assert_valid Factory.create(:asset, :model => Factory.create(:model))
  end
end
