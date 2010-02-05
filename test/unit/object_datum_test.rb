require 'test_helper'

class ObjectDatumTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:object_datum)
  end

  should "allow eng unit type" do
    assert_valid Factory.create(:object_datum, :eng_unit_type => Factory.create(:eng_unit_type))
  end
end
