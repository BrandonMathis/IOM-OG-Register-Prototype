require 'test_helper'

class ModelTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:model)
  end
end
