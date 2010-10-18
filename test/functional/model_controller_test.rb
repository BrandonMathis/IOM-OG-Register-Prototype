require 'test_helper'

class ModelControllerTest < ActionController::TestCase
  context "creating a model" do
    setup do
      @model_guid = "AF0D7BC4-1917-4B87-B618-72CB42C18456"
    end
    should "should create a model" do
      assert_difference('Model.count') do
        post :create, :model => { }
      end
      assert_redirected_to new_asset_path
    end
    should "create a model with tag given" do
      serial_no = "1234-ABCD"
      post :create, :model => {:g_u_i_d => @model_guid, :tag => "1234-ABCD" }
      assert_equal "1234-ABCD", Model.find_by_guid(@model_guid).tag
    end
    should "create a model with name given" do
      serial_no = "1234-ABCD"
      post :create, :model => {:g_u_i_d => @model_guid, :name => "1234-ABCD" }
      assert_equal "1234-ABCD", Model.find_by_guid(@model_guid).name
    end
    should "create a model with name ID" do
      serial_no = "1234-ABCD"
      post :create, :model => {:g_u_i_d => @model_guid, :i_d_in_info_source => "1234-ABCD" }
      assert_equal "1234-ABCD", Model.find_by_guid(@model_guid).i_d_in_info_source
    end
    should "create model with default tag if none is specified" do
      post :create, :model =>{:g_u_i_d => @model_guid}
      assert_equal "Model: "+@model_guid, Model.find_by_guid(@model_guid).tag
    end
    should "create model with default name if none is specified" do
      post :create, :model =>{:g_u_i_d => @model_guid}
      assert_equal "Model: "+@model_guid, Model.find_by_guid(@model_guid).name
    end
  end
end
