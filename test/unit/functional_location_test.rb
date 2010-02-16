require 'test_helper'

class FunctionalLocationTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:functional_location)
  end

end
