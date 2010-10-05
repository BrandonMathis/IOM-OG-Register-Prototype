require 'test_helper'

class ModelTest < ActiveSupport::TestCase
  should "contain product information in list of fields" do
    m = Model.create()
    assert m.field_names.include? :product_family
    assert m.field_names.include? :product_family_member
    assert m.field_names.include? :product_family_member_revision
    assert m.field_names.include? :part_number
  end
  
  should "contain product information in the list of attributes" do
    m = Model.create()
    assert m.attribute_names.include? :product_family
    assert m.attribute_names.include? :product_family_member
    assert m.attribute_names.include? :product_family_member_revision
    assert m.attribute_names.include? :part_number
  end
  
  should "be valid from factory" do
    assert_valid Factory.create(:model)
  end
  
  context "duplicating the entity" do
    setup do
      @type = Factory.create(:object_type)
      @model1 = Factory.create(:model, :object_type => @type)
      @model2 = @model1.dup_entity
    end
    should "create two unique objects" do
      assert_not_equal @model1, @model2
      assert_equal @model1.guid, @model2.guid
    end
    should "copy all attributes" do
      @model1.field_names.each do |field|
        assert_equal @model1.send("#{field}"), @model2.send("#{field}")
      end
    end
    should "copy the model's type" do
      assert @model1.object_type
      assert @model2.object_type
      @model1.object_type.field_names do |field|
        assert_equal @model1.object_type.send("#{field}"), @model2.object_type.send("#{field}")
      end
    end
    context "with new guids" do
      setup do
        @model2 = @model1.dup_entity(:gen_new_guids => true)
      end
      should "not gen a new guid for the model" do
        assert_equal @model1.guid, @model2.guid
      end
      should "not gen a new guids for the model's type" do
        assert @model1.object_type
        assert @model2.object_type
        assert_equal @model1.object_type.guid, @model2.object_type.guid
      end
    end
  end
end
