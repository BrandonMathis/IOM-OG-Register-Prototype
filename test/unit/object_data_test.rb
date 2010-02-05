require 'test_helper'

class ObjectDataTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:object_data)
  end

  should "allow eng unit type" do
    assert_valid Factory.create(:object_data, :eng_unit_type => Factory.create(:eng_unit_type))
  end
end
