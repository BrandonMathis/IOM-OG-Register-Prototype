require 'test_helper'

class AssetsControllerTest < ActionController::TestCase
  context "Asset controller" do
    setup do
      @type = Factory.create(:type)
      @network = Factory.create(:valid_network)
      @asset = Factory.create(:asset, :valid_network => @network, :type => @type)
    end
    
    should "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:assets)
    end

    should "should get new" do
      get :new
      assert_response :success
    end
    
    context "creating an asset" do
      setup do
        @asset_guid = "AF0D7BC4-1917-4B87-B618-72CB42C18456"
      end
      
      should "should create an asset" do
        assert_difference('Asset.count') do
          post :create, :asset => { }
        end
        assert_redirected_to asset_path(assigns(:asset))
      end
    
      should "give Undetermined type when type is not defined" do
        post :create, :asset => { :g_u_i_d => @asset_guid }
        assert_redirected_to asset_path(assigns(:asset))
        assert_equal Type.undetermined.guid, Asset.find_by_guid(@asset_guid).type.guid
      end
    
      should "give Asset: GUID for an undetermined name" do
        post :create, :asset => { :g_u_i_d => @asset_guid }
        assert_equal Asset.find_by_guid(@asset_guid).name, "Asset: " << @asset_guid
      end
    end

    should "should show asset" do
      get :show, :id => @asset.g_u_i_d
      assert_response :success
    end

    should "should get edit" do
      get :edit, :id => @asset.g_u_i_d
      assert_response :success
    end

    should "should update asset" do
      put :update, :id => @asset.g_u_i_d, :asset => { :tag => "test"}
      assert_redirected_to asset_path(assigns(:asset))
      assert_equal "test", Asset.find_by_guid(@asset.g_u_i_d).tag         #Yoda condition
    end

    should "should destroy asset" do
      assert_difference('Asset.count', -1) do
        delete :destroy, :id => @asset.g_u_i_d
      end

      assert_redirected_to assets_path
    end
  end
end