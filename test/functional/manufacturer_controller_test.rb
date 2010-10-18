require 'test_helper'

class ManufacturerControllerTest < ActionController::TestCase
  context "creating a model" do
    setup do
      @manufacturer_guid = "AF0D7BC4-1917-4B87-B618-72CB42C18456"
    end
    should "should create a model" do
      assert_difference('Manufacturer.count') do
        post :create, :manufacturer => { }
      end
      assert_redirected_to new_asset_path
    end
    should "create a model with tag given" do
      post :create, :manufacturer => {:g_u_i_d => @manufacturer_guid, :tag => "1234-ABCD" }
      assert_equal "1234-ABCD", Manufacturer.find_by_guid(@manufacturer_guid).tag
    end
    should "create a model with name given" do
      serial_no = "1234-ABCD"
      post :create, :manufacturer => {:g_u_i_d => @manufacturer_guid, :name => "1234-ABCD" }
      assert_equal "1234-ABCD", Manufacturer.find_by_guid(@manufacturer_guid).name
    end
    should "create a model with name ID" do
      serial_no = "1234-ABCD"
      post :create, :manufacturer => {:g_u_i_d => @manufacturer_guid, :i_d_in_info_source => "1234-ABCD" }
      assert_equal "1234-ABCD", Manufacturer.find_by_guid(@manufacturer_guid).i_d_in_info_source
    end
    should "create manufacturer with default tag if none is specified" do
      post :create, :manufacturer =>{:g_u_i_d => @manufacturer_guid}
      assert_equal "Manufacturer: "+@manufacturer_guid, Manufacturer.find_by_guid(@manufacturer_guid).tag
    end
    should "create manufacturer with default name if none is specified" do
      post :create, :manufacturer =>{:g_u_i_d => @manufacturer_guid}
      assert_equal "Manufacturer: "+@manufacturer_guid, Manufacturer.find_by_guid(@manufacturer_guid).name
    end
  end
end
