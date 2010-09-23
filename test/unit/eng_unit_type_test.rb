require 'test_helper'

class EngUnitTypeTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:eng_unit_type)
  end
  
  context "duplicating the entity" do
    setup do
      @unit1 = Factory.create(:eng_unit_type)
      @unit2 = @unit1.dup_entity(:gen_new_guids => true)
    end
    should "create a new object" do
      assert_not_equal @unit1, @unit2
    end
    should "not generate a new guid" do
      assert_equal @unit1.guid, @unit2.guid
    end
  end
end
