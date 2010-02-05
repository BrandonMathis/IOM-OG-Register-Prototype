require 'test_helper'

class AttributeTypeTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:attribute_type)
  end
end
