require 'test_helper'

class TopologiesControllerTest < ActionController::IntegrationTest
  def setup
    super
    @sub_location = Factory.create(:segment,
                                   :user_tag => "01G-7A Kerosene Pump Package")
    target = Factory.create(:network_connection, :source => @sub_location)
    @functional_location = Factory.create(:segment, :user_tag => "CU-1")
    entry_point = Factory.create(:network_connection,
                                 :source => @functional_location,
                                 :targets => [target])
    @topology = Factory.create(:topology_asset,
                               :user_tag => "Topology Asset",
                               :user_name => "My long winded name for this topology",
                               :id_in_source => "19837418734192874319784",
                               :source_id => "www.example.com/cris/v1.0",
                               :entry_point => entry_point)
    
  end
  
  context "with a topology with a source and a single functional location" do
    setup do
      #
      visit topology_url(@topology)
    end

    should_respond_with :success

    should "display the topology's user tag" do
      assert_match @topology.user_tag, response.body, "Didn't find topology user tag in response body"
    end

    should "display the topology's source's user tag" do
      assert_match @functional_location.user_tag, response.body, "Didn't find source user_tag in response body"
    end

    should "render the sub location's user tag as a nested unordered list" do
      assert_select "li", /#{@sub_location.user_tag}/, response.body
    end
    context "clicking on the functional location" do
      setup do
        click_link @functional_location.user_tag
      end
      should_respond_with :success
    end
  end


  context "getting the index" do
    setup do
      @asset = Factory.create(:serialized_asset, :user_tag => "This should not appear")
      visit topologies_url
    end
    should_respond_with :success

    should "link to our topology asset's user tag" do
      assert_select "a[href=?]", topology_url(@topology), @topology.user_tag
    end

    should "not link to serialized asset" do
      assert_not_contain @asset.user_tag
    end
  end
  
end
