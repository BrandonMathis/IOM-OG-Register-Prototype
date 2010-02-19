require 'test_helper'

class SegmentsControllerTest < ActionController::IntegrationTest

  def setup
    super
    @functional_location = Factory.create(:segment, :user_tag => "CU-1")

    @asset = Factory(:asset)
    @functional_location.installed_assets << @asset
    @functional_location.save
  end

  context "Displaying installed assets for a functional location" do
    setup do
      visit segment_url(@functional_location)
    end
    should_respond_with :success
    should "display the asset user tag" do
      assert_contain @asset.user_tag
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

      should("show the segment again") do
        assert_match segment_url(@functional_location), current_url
      end
      
      should_change("the number of installed assets on the segment", :by =>1){@functional_location.installed_assets.size}
    end
  end
end