require 'test_helper'

class EnterpriseControllerTest < ActionController::TestCase
  context "Deleting a CCOMEntity via RESTful call" do
    setup do
      @enterprise = Factory.create(:enterprise)
    end
    
    should 'delete the enterprise' do
      assert_difference('Enterprise.count', -1) do
        delete :destroy, :id => @enterprise.guid, :format => 'xml'
      end
    end
    
    should "return xml of destroyed enterprise" do
      delete :destroy, :id => @enterprise.guid, :format => 'xml'
      @doc = Nokogiri::XML.parse(@response.body)
      guid = @doc.mimosa_xpath("/CCOMData/Entity/GUID").first.content
      assert guid =~ /(^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$|^$)/
    end
    
    context "With a GUID that doesnt exsist in db" do
      setup do
        delete :destroy, :id => @enterprise.guid, :format => 'xml'
      end
      
      should 'give an error when GUID doesnt exsist' do
        delete :destroy, :id => @enterprise.guid, :format => 'xml'
        @doc = Nokogiri::XML.parse(@response.body)
        assert_equal @doc.xpath("/CCOMError/errorMessage").first.content, "Could not find requested CCOM Entity with given GUID"
        assert_equal @doc.xpath("/CCOMError/method").first.content, "deleteEntity"
        assert_equal @doc.xpath("/CCOMError/arguments/GUID").first.content, @enterprise.guid
      end
    end
  end
end
