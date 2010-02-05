require 'test_helper'

class NetworkTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:network)
  end

  should "support an entry point as a network connection" do
    assert_valid Factory.create(:network, :entry_points => [Factory.create(:network_connection)])
  end
end
