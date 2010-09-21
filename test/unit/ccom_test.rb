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
  
  context "Adding an asset to the database" do
    setup do
      @asset = Asset.create(
          :g_u_i_d => "Jung GUID",
          :tag => "Junk Tag",
          :name => "Junk Name",
          :i_d_in_info_source => "Junk ID",
          :last_edited => "Now",
          :status => "1")
    end
    
    should "have asset in list of uninstalled assets" do
      assert Asset.uninstalled.include?(@asset)
    end
  end
end