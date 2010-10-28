require 'test_helper'

class SuccessorTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:successor)
  end
end
