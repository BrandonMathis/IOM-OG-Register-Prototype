require 'test_helper'

class TopologiesControllerTest < ActionController::IntegrationTest
  def setup
    super
    @sub_location = Factory.create(:segment,
                                   :tag => "01G-7A Kerosene Pump Package")
    @functional_location = Factory.create(:segment, :tag => "CU-1")
    entry_edge = Factory.create(:network_connection,
                                 :source => @functional_location,
                                 :target => @sub_location)
    @topology = Factory.create(:topology_asset,
                               :tag => "Topology Asset",
                               :name => "My long winded name for this topology",
                               :i_d_in_info_source => "19837418734192874319784",
                               :entry_edge => entry_edge)
    
  end
  
  context "with a topology with a source and a single functional location" do
    setup do
      #
      visit topology_url(@topology)
    end

    should_respond_with :success

    should "display the topology's user tag" do
      assert_match @topology.tag, response.body, "Didn't find topology user tag in response body"
    end

    should "display the topology's source's user tag" do
      assert_match @functional_location.tag, response.body, "Didn't find source user_tag in response body"
    end

    should "render the sub location's user tag as a nested unordered list" do
      assert_select "li", /#{@sub_location.tag}/, response.body
    end
    context "clicking on the functional location" do
      setup do
        click_link @functional_location.tag
      end
      should_respond_with :success
    end
  end


  context "getting the index" do
    setup do
      @asset = Factory.create(:serialized_asset, :tag => "This should not appear")
      visit topologies_url
    end
    should_respond_with :success

    should "link to our topology asset's user tag" do
      assert_select "a[href=?]", topology_url(@topology), @topology.tag
    end

    should "not link to serialized asset" do
      assert_not_contain @asset.tag
    end
  end
  
end
