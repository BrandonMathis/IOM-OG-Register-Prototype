require 'test_helper'

class NetworkConnectionTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:network_connection)
  end

  should "have a segment as a source" do
    assert_valid Factory.create(:network_connection, :source => Factory.create(:segment))
  end
end
