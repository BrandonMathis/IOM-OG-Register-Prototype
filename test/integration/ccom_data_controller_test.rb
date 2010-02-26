require 'test_helper'

class CcomDataControllerTest < ActionController::IntegrationTest

  context "getting the ccom data index" do
    setup do
      get ccom_data_url
    end
    should_respond_with :success

    context "uploading an xml file" do
      setup do
        attach_file "XML File", File.join(Rails.root, "db", "xml", "topology.xml")
        click_button "Upload"
      end
      should_respond_with :success
      should "have index template" do
        assert_template "index"
      end
      should_change("the number of entities") { CcomEntity.count }
      should "have some flash message" do
        assert flash[:notice]
      end
    end
  end

  context "with some data" do
    setup { Factory.create(:ccom_entity) }

    context "getting the destroy path" do
      setup do
        visit ccom_data_url
        click_link "Clear DB"
      end
      should "have an empty db" do
        [CcomEntity, Asset, Segment, MeasLocation, ObjectDatum].each do |object|
          assert_equal 0, object.send(:count), "Found some #{object.to_s}"
        end
      end
    end
  end

end
