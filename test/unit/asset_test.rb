require 'test_helper'

class AssetTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:asset)
  end

end
