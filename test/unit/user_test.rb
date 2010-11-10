require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "Is a valid factory" do
    @user = Factory.create(:user)
  end
end