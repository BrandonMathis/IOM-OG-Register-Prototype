require 'test_helper'

class SegmentsControllerTest < ActionController::IntegrationTest

  def setup
    super
    @functional_location = Factory.create(:segment, :user_tag => "CU-1", :user_name => "Something other than the user tag")

    @asset = Factory(:asset)
    @functional_location.installed_assets << @asset
    @functional_location.save
  end

  context "displaying a functional location" do
    setup do
      visit segment_url(@functional_location)
    end

    should "have the some of the ccom entity details displayed" do
      [:guid, :user_name].each do |attr|
        assert_contain @functional_location.send(attr)
      end
    end
  end

  context "Displaying installed assets for a functional location" do
    setup do
      visit segment_url(@functional_location)
    end
    should_respond_with :success
    should "display the asset user tag" do
      assert_contain @asset.user_tag
    end

    context "uninstalling an asset" do
      setup do
        click_button "uninstall-#{@asset.guid}"
      end
      should "flash a message about uninstalling the asset" do
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
      assert_select "option", @uninstalled_asset.user_tag
    end
    context "and really doing it" do
      setup do
        select @uninstalled_asset.user_tag
        click_button "Install"
      end

      should "flash a message about installing the asset" do
        assert_contain /Installed.*#{@uninstalled_asset.user_tag}/
      end

      should("show the segment again") do
        assert_match segment_url(@functional_location), current_url
      end
      
      should_change("the number of installed assets on the segment", :by =>1){@functional_location.installed_assets.size}
    end
  end
end
