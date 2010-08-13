require 'test_helper'

class SegmentsControllerTest < ActionController::IntegrationTest

  def setup
    super
    @functional_location = Factory.create(:segment, :tag => "CU-1", 
                                          :name => "Something other than the user tag",
                                          :type => nil)

    @asset = Factory(:asset)
    @functional_location.installed_assets << @asset
    @functional_location.save
  end

  context "displaying a functional location" do
    setup do
      visit segment_url(@functional_location)
    end

    should "have the some of the ccom entity details displayed" do
      [:g_u_i_d, :name].each do |attr|
        assert_contain @functional_location.send(attr)
      end
    end

    context "with an object type" do
      setup do
        @object_type = Factory.create(:type, :tag => "some object type")
        @functional_location.type = @object_type
        @functional_location.save
        @functional_location = Segment.find_by_guid(@functional_location.g_u_i_d)
        visit segment_url(@functional_location)
      end
      should "have a new object type" do
        assert_equal @object_type, @functional_location.type
      end
      should_respond_with :success
      should "have the object type's details" do
        [:g_u_i_d, :tag].each do |attr|
          assert_contain @object_type.send(attr)
        end
      end
    end
  end

  context "Displaying installed assets for a functional location" do
    setup do
      visit segment_url(@functional_location)
    end
    should_respond_with :success
    should "display the asset user tag" do
      assert_contain @asset.tag
    end

    context "uninstalling an asset" do
      setup do
        click_button "uninstall-#{@asset.g_u_i_d}"
      end
      should_eventually "flash a message about uninstalling the asset" do
        assert_contain /Uninstalled.*#{@asset.user_tag}/
      end

      should("show the segment again") do
        assert_match segment_url(@functional_location), current_url
      end
      should_change("the number of installed assets on the segment", :by => -1) { @functional_location.installed_assets.size }
    end
  end

  context "installing assets" do
    setup do
      @uninstalled_asset = Factory(:asset)
      visit segment_url(@functional_location)
    end
    should "show the uninstalled asset in a select list" do
      assert_select "option", @uninstalled_asset.tag
    end
    context "and really doing it" do
      setup do
        select @uninstalled_asset.tag
        click_button "Install"
      end

      should_eventually "flash a message about installing the asset" do
        assert_contain /Installed.*#{@uninstalled_asset.user_tag}/
      end

      should("show the segment again") do
        assert_match segment_url(@functional_location), current_url
      end
      
      should_change("the number of installed assets on the segment", :by =>1){@functional_location.installed_assets.size}
    end
  end

  context "a functional location with a datasheet" do
    setup do
      @obj_data1 = ObjectDatum.create_from_fields("2300", "Armature Voltage, Rated", "Volts")
      @obj_data2 = ObjectDatum.create_from_fields("42", "Armature Voltage, unrated", "Volts")
      @meas_loc1 = Factory.create(:meas_location, 
                                  :tag => "VLT-RAT",
                                  :object_data => [@obj_data1, @obj_data2])
      @segment = Factory.create(:segment, :tag => "ELEC SPEC", :meas_locations => [@meas_loc1])
      
      ep = Factory.create(:network_connection, :source => @segment)
      network = Factory.create(:network, :entry_edges => [ep])
      scn = SegmentConfigNetwork.create(:network => network)
      @functional_location = Factory.create(:segment, :segment_config_network => scn)
      visit segment_url(@functional_location)
    end

    should "have the meas loc's user tag" do
      assert_select "tr > td.user_tag", @meas_loc1.tag
    end

    should "have the meas loc's attribute type" do
      assert_select "tr > td.attribute_type", @obj_data1.attribute_user_tag
    end

  end
end
