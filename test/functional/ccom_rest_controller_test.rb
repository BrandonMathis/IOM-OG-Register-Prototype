require 'test_helper'

class CcomRestControllerTest < ActionController::TestCase
  context "rest controller" do
    setup do
      @entity = Factory.create(:ccom_entity)
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
end
