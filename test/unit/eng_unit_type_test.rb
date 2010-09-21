require 'test_helper'

class EngUnitTypeTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:eng_unit_type)
  end
end
