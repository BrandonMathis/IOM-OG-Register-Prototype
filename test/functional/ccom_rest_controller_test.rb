require 'test_helper'

class CcomRestControllerTest < ActionController::TestCase
  context "Deleting a CCOMEntity via RESTful call" do
    setup do
      @entity = Factory.create(:ccom_entity)
    end
    
    should 'delete the entity' do
      assert_difference('CcomEntity.count', -1) do
        delete :destroy, :id => @entity.g_u_i_d, :format => 'xml'
      end
    end
    
    should "return xml of destroyed entity" do
      delete :destroy, :id => @entity.guid, :format => 'xml'
      @doc = Nokogiri::XML.parse(@response.body)
      guid = @doc.mimosa_xpath("/CCOMData/Entity/GUID").first.content
      assert guid =~ /(^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$|^$)/
    end
    
    context "With a GUID that doesnt exsist in db" do
      setup do
        delete :destroy, :id => @entity.g_u_i_d, :format => 'xml'
      end
      
      should 'give an error when GUID doesnt exsist' do
        delete :destroy, :id => @entity.g_u_i_d, :format => 'xml'
        @doc = Nokogiri::XML.parse(@response.body)
        assert @doc.xpath("/APIError/URL").first.content
        assert_equal @doc.xpath("/APIError/ErrorMessage").first.content, "Could not find requested CCOM Entity with given GUID"
        assert_equal @doc.xpath("/APIError/HTTPMethod").first.content, "DELETE"
      end
    end
  end
end
