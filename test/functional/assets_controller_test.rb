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
      should "create an asset with a serial number if given" do
        serial_no = "1234-ABCD"
        post :create, :asset => {:g_u_i_d => @asset_guid, :serial_number => "1234-ABCD" }
        assert_equal "1234-ABCD", Asset.find_by_guid(@asset_guid).serial_number
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
      should "attach a model when a model is given" do
        model = Factory.create(:model)
        post :create, :asset => {:g_u_i_d => @asset_guid, :model => model.guid}
        assert_equal Asset.find_by_guid(@asset_guid).model, model
        assert_equal Asset.find_by_guid(@asset_guid).model.product_family, model.product_family
      end
      should "attach a manufacturer when a manufacturer is given" do
        manufacturer = Factory.create(:manufacturer)
        post :create, :asset => {:g_u_i_d => @asset_guid, :manufacturer => manufacturer.guid}
        assert_equal Asset.find_by_guid(@asset_guid).manufacturer, manufacturer
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
      assert_equal "test", Asset.find_by_guid(@asset.g_u_i_d).tag
    end

    should "should destroy asset" do
      assert_difference('Asset.count', -1) do
        delete :destroy, :id => @asset.g_u_i_d
      end

      assert_redirected_to assets_path
    end
  end
  context "creating an Asset via RESTful call with XML" do
    setup do
      @guid = 'C18340CE-23D3-4B69-A7D4-6BC5378BA0D2'
    end
    context "using good XML" do
      setup do
        @request.env['RAW_POST_DATA'] = '
        <?xml version="1.0" encoding="UTF-8"?>
    		<CCOMData xmlns="http://www.mimosa.org/osa-eai/v3-2/xml/CCOM-ML" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    		<Entity xsi:type="Asset">
    		        <GUID>'+@guid+'</GUID>
    		        <IDInInfoSource>0000083500000001.25</IDInInfoSource>
    		        <Tag>A Sample Asset</Tag>
    		        <Name>Sample Asset</Name>
    		        <Status>1</Status>
    		        <Type>
    		          <GUID>b0f69ccc-3d42-4055-90f3-5aec8ff4dc1d</GUID>
    		          <IDInInfoSource>0000000000000000.0.147</IDInInfoSource>
    		          <Tag>Ambient Atmosphere</Tag>
    		          <Name>Ambient Atmosphere</Name>
    		          <Status>1</Status>
    		        </Type>
    		</Entity>
    		<Entity xsi:type="Asset">
    		        <GUID>A18340CE-23D3-4B69-A7D4-6BC5378BA0D2</GUID>
    		        <IDInInfoSource>0000083500000001.25</IDInInfoSource>
    		        <Tag>A Sample Asset</Tag>
    		        <Name>Sample Asset</Name>
    		        <Status>1</Status>
    		        <Type>
    		          <GUID>b0f69ccc-3d42-4055-90f3-5aec8ff4dc1d</GUID>
    		          <IDInInfoSource>0000000000000000.0.147</IDInInfoSource>
    		          <Tag>Ambient Atmosphere</Tag>
    		          <Name>Ambient Atmosphere</Name>
    		          <Status>1</Status>
    		        </Type>
    		</Entity>
    		</CCOMData>'
  		end
  		should 'add an asset to the database' do
        assert_difference("Asset.count", +2) do
          post :create, :format => 'xml'
        end
      end
      should 'give that asset the specified guid' do
        post :create, :format => 'xml'
        assert Asset.find_by_guid(@guid)
      end
      should 'return the XML of the generated entity with set las updated time' do
        post :create, :format => 'xml'
        RAILS_DEFAULT_LOGGER.debug(response.body.read)
      end
    end
  end
end