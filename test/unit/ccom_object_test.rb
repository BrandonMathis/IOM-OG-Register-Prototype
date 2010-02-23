require 'test_helper'

class CcomObjectTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:ccom_object)
  end

  context "importing xml for a new entity" do
    setup do
      @object_type = Factory.create(:object_type)
      @ccom_object = Factory.create(:ccom_object, :user_tag => "foobar", 
                                    :object_type => @object_type)
      @ccom_object.guid = UUID.generate
      @parsed_object = CcomObject.from_xml(@ccom_object.to_xml)
    end

    should "have the right details" do
      [:guid, :user_tag].each do |attr|
        assert_equal @ccom_object.send(attr), @parsed_object.send(attr)
      end
    end

    should "have the right object type" do
      assert_equal @object_type, @parsed_object.object_type, @ccom_object.to_xml
    end
  end

end
