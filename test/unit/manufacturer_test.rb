require 'test_helper'

class ManufacturerTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:manufacturer)
  end
  
  context "duplicating the manufacturer" do
    setup do
      @type = Factory.create(:type)
      @man1 = Factory.create(:manufacturer, :type => @type)
      @man2 = @man1.dup_entity
    end
    should "create two separate objects" do
      assert_not_equal @man1, @man2
      assert_equal @man1.guid, @man2.guid
    end
    should "copy all attributes" do
      @man1.field_names.each do |field|
        assert_equal @man1.send("#{field}"), @man2.send("#{field}")
      end
    end
    should "have a type" do
      assert @man2.type
    end
    should "copy the type" do
      assert_equal @man1.type.guid, @man2.type.guid
      @man1.field_names.each do |field|
        assert_equal @man1.type.send("#{field}"), @man2.type.send("#{field}")
      end
    end
    context "with unique guids" do
      setup do
        @man2 = @man1.dup_entity(:gen_new_guids => true)
      end
      should "create two identical type guids" do
        assert_equal @man1.type.guid, @man2.type.guid
      end
      should "create identical guids for the manufacturers" do
        assert_equal @man1.guid, @man2.guid
      end
    end
  end
end
