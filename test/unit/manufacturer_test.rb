require 'test_helper'

class ManufacturerTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:manufacturer)
  end
end
