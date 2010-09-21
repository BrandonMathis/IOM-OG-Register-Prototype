require 'test_helper'

class CcomObjectTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:ccom_object)
  end

  context "importing xml for a new entity" do
    setup do
      @object_type = Factory.create(:type)
      @ccom_object = Factory.create(:ccom_object, :tag => "foobar", 
                                    :type => @object_type)
      @ccom_object.g_u_i_d = UUID.generate
      @parsed_object = CcomObject.from_xml(@ccom_object.to_xml)
    end

    should "have the right details" do
      [:g_u_i_d, :tag].each do |attr|
        assert_equal @ccom_object.send(attr), @parsed_object.send(attr)
      end
    end

    should "have the right object type" do
      assert_equal @object_type, @parsed_object.type, @ccom_object.to_xml
    end
  end
  
  context "duplicating a ccom object" do
    setup do
      @object1 = Factory.create(:ccom_object)
      @object2 = @object1.dup_entity
    end
    
    should "create a new object with identical attributes" do
      @object1.field_names.each do |attr|
        assert_equal @object1.send(attr), @object2.send(attr)
      end
    end
    
    context "with gen_new_guids on" do
      setup do
        @object2 = @object1.dup_entity(:gen_new_guids => true)
      end
      
      should "generate a new guid" do
        assert_not_equal @object1.guid, @object2.guid
      end
    end
  end
  context "duplicating a ccom entity with no children" do
    setup do
      @entity1 = Factory.create(:ccom_object)
      @entity2 = @entity1.dup_entity
    end
    
    should "duplicate a separate object with unique ID" do
      assert_not_equal @entity1 , @entity2
    end
    
    should "Copy GUID of entity" do
      assert_equal @entity1.guid , @entity2.guid
    end
    
    should "Generate new GUID if option is selected" do
      assert_not_equal @entity1.guid , @entity1.dup_entity(:gen_new_guids => true).guid
    end
  end   
end
