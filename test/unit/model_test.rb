require 'test_helper'

class ModelTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:model)
  end
  
  context "duplicating the entity" do
    setup do
      @type = Factory.create(:type)
      @model1 = Factory.create(:model, :type => @type)
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
      assert @model1.type
      assert @model2.type
      @model1.type.field_names do |field|
        assert_equal @model1.type.send("#{field}"), @model2.type.send("#{field}")
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
        assert @model1.type
        assert @model2.type
        assert_equal @model1.type.guid, @model2.type.guid
      end
    end
  end
end
