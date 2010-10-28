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
  
  context "Deleting a CCOMEntity via RESTful call" do
    setup do
      @model = Factory.create(:model)
    end
    
    should 'delete the model' do
      assert_difference('Model.count', -1) do
        delete :destroy, :id => @model.guid, :format => 'xml'
      end
    end
    
    should "return xml of destroyed model" do
      delete :destroy, :id => @model.guid, :format => 'xml'
      @doc = Nokogiri::XML.parse(@response.body)
      guid = @doc.mimosa_xpath("/CCOMData/Entity/GUID").first.content
      assert guid =~ /(^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$|^$)/
    end
    
    context "With a GUID that doesnt exsist in db" do
      setup do
        delete :destroy, :id => @model.guid, :format => 'xml'
      end
      
      should 'give an error when GUID doesnt exsist' do
        delete :destroy, :id => @model.guid, :format => 'xml'
        @doc = Nokogiri::XML.parse(@response.body)
        assert_equal @doc.xpath("/CCOMError/errorMessage").first.content, "Could not find requested CCOM Entity with given GUID"
        assert_equal @doc.xpath("/CCOMError/method").first.content, "deleteEntity"
        assert_equal @doc.xpath("/CCOMError/arguments/GUID").first.content, @model.guid
      end
    end
  end
end
