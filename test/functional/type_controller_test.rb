require 'test_helper'

class TypeControllerTest < ActionController::TestCase
  context "rest controller" do
    setup do
      @entity = Factory.create(:object_type)
    end
    should "Delete the CCOM Entity and return the deleted entities XML" do
      delete :destroy, :id => @entity.guid, :format => 'xml'
      @doc = Nokogiri::XML.parse(@response.body)
      guid = @doc.mimosa_xpath("/CCOMData/Entity/GUID").first.content
      assert guid =~ /(^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$|^$)/
    end
    should "deleted the entity" do
      assert_difference('CcomEntity.count', -1) do
        delete :destroy, :id => @entity.g_u_i_d, :format => 'xml'
      end
    end
  end
  
  context "Deleting a CCOMEntity via RESTful call" do
    setup do
      @object_type = Factory.create(:object_type)
    end
    
    should 'delete the object_type' do
      assert_difference('ObjectType.count', -1) do
        delete :destroy, :id => @object_type.guid, :format => 'xml'
      end
    end
    
    should "return xml of destroyed object_type" do
      delete :destroy, :id => @object_type.guid, :format => 'xml'
      @doc = Nokogiri::XML.parse(@response.body)
      guid = @doc.mimosa_xpath("/CCOMData/Entity/GUID").first.content
      assert guid =~ /(^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$|^$)/
    end
    
    context "With a GUID that doesnt exsist in db" do
      setup do
        delete :destroy, :id => @object_type.guid, :format => 'xml'
      end
      
      should 'give an error when GUID doesnt exsist' do
        delete :destroy, :id => @object_type.guid, :format => 'xml'
        @doc = Nokogiri::XML.parse(@response.body)
        assert_equal @doc.xpath("/CCOMError/errorMessage").first.content, "Could not find requested CCOM Entity with given GUID"
        assert_equal @doc.xpath("/CCOMError/method").first.content, "deleteEntity"
        assert_equal @doc.xpath("/CCOMError/arguments/GUID").first.content, @object_type.guid
      end
    end
  end
end
