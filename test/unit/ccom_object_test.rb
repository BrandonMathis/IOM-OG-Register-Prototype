require 'test_helper'

class CcomObjectTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:ccom_object)
  end
end
