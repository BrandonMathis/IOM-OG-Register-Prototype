require 'test_helper'

class CcomTest < ActiveSupport::TestCase
  
  should "be valid from factory" do
    assert_valid Factory.create(:ccom_entity)
  end
  
  should "find by guid" do
    entity = Factory.create(:ccom_entity)
    assert_not_nil found = CcomEntity.find_by_guid(entity.g_u_i_d)
    assert_equal found, entity
  end
end