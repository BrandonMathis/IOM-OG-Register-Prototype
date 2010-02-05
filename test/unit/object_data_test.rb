require 'test_helper'

class ObjectDataTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:object_data)
  end
end
