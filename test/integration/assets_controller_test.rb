require 'test_helper'

class AssetsControllerTest < ActionController::IntegrationTest

  context "with an asset and a single segment datasheet" do
    setup do
      @attr_type = Factory.create(:attribute_type, :user_tag => "Armature Voltage, Rated")
      @eng_unit = Factory.create(:eng_unit_type, :user_tag => "Volts")
      @obj_data = Factory.create(:object_datum, :data => "2300", 
                                 :attribute_type => @attr_type, :eng_unit_type => @eng_unit)
      @meas_loc1 = Factory.create(:meas_location, :object_data => @obj_data)
      @segment = Factory.create(:segment, :user_tag => "ELEC SPEC", :meas_locations => [@meas_loc1])
      
      ep = Factory.create(:network_connection, :source => @segment)
      @asset = Factory.create(:asset, :entry_points => [ep])

      visit asset_url(@asset)
    end

    should_respond_with :success

    should "have the segment's user tag" do
      assert_select "h1", @segment.user_tag
    end

    should "have the meas loc's user tag" do
      assert_select "tr[id=?] > td.user_tag", @meas_loc1.guid, @meas_loc1.user_tag
    end

    should "have the meas loc's attribute type" do
      assert_select "tr[id=?] > td.attribute_type", @meas_loc1.guid, @attr_type.user_tag
    end

    should "have the meas loc's data value" do
      assert_select "tr[id=?] > td.object_data", @meas_loc1.guid, "2300 Volts"
    end
  end
end
