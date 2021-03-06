require 'test_helper'

class EngUnitTypeControllerTest < ActionController::TestCase
  context "Deleting a CCOMEntity via RESTful call" do
    setup do
      @unit_type = Factory.create(:eng_unit_type)
    end
    
    should 'delete the unit_type' do
      assert_difference('EngUnitType.count', -1) do
        delete :destroy, :id => @unit_type.guid, :format => 'xml'
      end
    end
    
    should "return xml of destroyed unit_type" do
      delete :destroy, :id => @unit_type.guid, :format => 'xml'
      @doc = Nokogiri::XML.parse(@response.body)
      guid = @doc.mimosa_xpath("/CCOMData/Entity/GUID").first.content
      assert guid =~ /(^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$|^$)/
    end
    
    context "With a GUID that doesnt exsist in db" do
      setup do
        delete :destroy, :id => @unit_type.guid, :format => 'xml'
      end
      
      should 'give an error when GUID doesnt exsist' do
        delete :destroy, :id => @unit_type.guid, :format => 'xml'
        @doc = Nokogiri::XML.parse(@response.body)
        assert @doc.xpath("/APIError/URL").first.content
        assert_equal "Could not find requested CCOM Entity with given GUID", @doc.xpath("/APIError/ErrorMessage").first.content
        assert_equal "DELETE", @doc.xpath("/APIError/HTTPMethod").first.content
        assert_equal "404", @doc.xpath("/APIError/HTTPError").first.content
        assert_equal "Mimosa3", @doc.xpath("/APIError/ErrorCode").first.content
      end
    end
  end
end
