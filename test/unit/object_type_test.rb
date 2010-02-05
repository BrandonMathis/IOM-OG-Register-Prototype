require 'test_helper'

class ObjectTypeTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:object_type)
  end
end
