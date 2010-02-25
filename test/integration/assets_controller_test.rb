require 'test_helper'
require 'factories'

class AssetsControllerTest < ActionController::IntegrationTest

  context "with an asset and a single segment datasheet" do
    setup do
      @obj_data1 = ObjectDatum.create_from_fields("2300", "Armature Voltage, Rated", "Volts")
      @obj_data2 = ObjectDatum.create_from_fields("42", "Armature Voltage, unrated", "Volts")
      @meas_loc1 = Factory.create(:meas_location, :object_data => [@obj_data1, @obj_data2])
      @segment = Factory.create(:segment, :user_tag => "ELEC SPEC", :meas_locations => [@meas_loc1])
      
      @obj_data3 = ObjectDatum.create_from_fields("123", "Yippie Skippie", "Seconds")
      @meas_loc2 = Factory.create(:meas_location, :object_data => [@obj_data3])
      @seg2 = Factory.create(:segment, :meas_locations => [@meas_loc2])
      target = Factory.create(:network_connection, :source => @seg2)
      ep = Factory.create(:network_connection, :source => @segment, :targets => [target])
      @asset = Factory.create(:asset, :entry_points => [ep])

    end

    context "visiting the index" do
      setup do
        @topology = Factory.create(:topology_asset)
        visit assets_url
      end
      should_respond_with :success
      should "link to the asset" do
        assert_select "a[href=?]", asset_url(@asset), @asset.user_tag
      end
      should "not have the topology" do
        assert_not_contain @topology.user_tag
      end
    end

    context "visiting the show page" do
      setup { visit asset_url(@asset) }


      should_respond_with :success

      should "have the segment's user tag" do
        assert_select "h1", @segment.user_tag
      end

      should "have the meas loc's user tag" do
        assert_select "tr > td.user_tag", @meas_loc1.user_tag
      end

      should "have the meas loc's attribute type" do
        assert_select "tr > td.attribute_type", @obj_data1.attribute_user_tag
      end

      should "have the meas loc's data value" do
        assert_select "tr > td.object_data", @obj_data1.value
      end

      should "have the meas loc's second attribute type" do
        assert_select "tr > td.attribute_type", @obj_data2.attribute_user_tag
      end

      should "have the meas loc's second data value" do
        assert_select "tr > td.object_data", @obj_data2.value
      end

      should "have the nested segment's user tag" do
        assert_select "h2", @seg2.user_tag
      end
    end
  end
end
