require 'test_helper'

class TopologiesTest < ActionController::IntegrationTest
  
  context "with a topology with a source and a single functional location" do
    setup do
      #
      functional_location = Factory.create(:segment, 
                                           :user_tag => "01G-7A Kerosene Pump Package")
      target = Factory.create(:network_connection,
                              :source => functional_location)
      @source = Factory.create(:segment, :user_tag => "CU-1")
      entry_point = Factory.create(:network_connection, :source => @source)
      network = Factory.create(:network,
                               :entry_points => [entry_point])
      @topology = Factory.create(:topology_asset, 
                                 :user_tag => "Topology Asset",
                                 :user_name => "My long winded name for this topology",
                                 :id_in_source => "19837418734192874319784",
                                 :source_id => "www.example.com/cris/v1.0",
                                 :network => network)
      visit topology_url(:id => @topology.guid)
    end

    should_respond_with :success
    should "display the basic ccom data" do
      [:guid, :user_tag, :id_in_source, :source_id, :user_name].each do |attr|
        assert_match @topology.send(attr), response.body, "Didn't find topology #{attr} in response body"
      end
    end

    should "display the topology's source's basic data" do
      [:guid, :user_tag, :id_in_source, :source_id, :user_name].each do |attr|
        assert_match @source.send(attr), response.body, "Didn't find source #{attr} in response body"
      end
    end
  end
end
