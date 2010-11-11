require 'test_helper'

class CcomDataControllerTest < ActionController::TestCase
  context "with some data" do
    setup do
      Factory.create(:ccom_entity)
    end

    context "getting the destroy path" do
      setup do
        get :delete_all
      end
      should "have an empty db" do
        [CcomEntity, Asset, Segment, MeasLocation, ObjectDatum].each do |object|
          assert_equal 0, object.send(:count), "Found some #{object.to_s} #{Mongoid.database.name}"
        end
      end
    end
  end
end
