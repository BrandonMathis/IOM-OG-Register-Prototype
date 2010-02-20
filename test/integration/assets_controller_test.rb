require 'test_helper'

class AssetsControllerTest < ActionController::IntegrationTest

  context "with an asset and a single segment datasheet" do
    setup do
      @attr_type1 = Factory.create(:attribute_type, :user_tag => "Armature Voltage, Rated")
      @eng_unit1 = Factory.create(:eng_unit_type, :user_tag => "Volts")
      @obj_data1 = Factory.create(:object_datum, :data => "2300", 
                                 :attribute_type => @attr_type1, :eng_unit_type => @eng_unit1)
      @attr_type2 = Factory.create(:attribute_type, :user_tag => "Armature 2")
      @eng_unit2 = Factory.create(:eng_unit_type, :user_tag => "Volts 2")
      @obj_data2 = Factory.create(:object_datum, :data => "00", 
                                 :attribute_type => @attr_type2, :eng_unit_type => @eng_unit2)
      @meas_loc1 = Factory.create(:meas_location, :object_data => [@obj_data1, @obj_data2])
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
      assert_select "tr > td.user_tag", @meas_loc1.user_tag
    end

    should "have the meas loc's attribute type" do
      assert_select "tr > td.attribute_type", @attr_type1.user_tag
    end

    should "have the meas loc's data value" do
      assert_select "tr > td.object_data", "2300 Volts"
    end

    should "have the meas loc's second attribute type" do
      assert_select "tr > td.attribute_type", @attr_type2.user_tag
    end

    should "have the meas loc's second data value" do
      assert_select "tr > td.object_data", "00 Volts 2"
    end
  end
end
