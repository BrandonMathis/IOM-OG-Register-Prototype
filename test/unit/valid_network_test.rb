require 'test_helper'

class ValidNetworkTest < ActiveSupport::TestCase
  context "deleting a valid network" do
    setup do
      @vnet = Factory.create(:valid_network)
      @vnet.destroy
    end
    should "delete the vnet" do
      assert !ValidNetwork.find_by_guid(@vnet.guid)
    end
  end
end