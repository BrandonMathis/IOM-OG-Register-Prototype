require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "Is a valid factory" do
    @user = Factory.create(:user)
    #use RAILS_DEFAULT_LOGGER.debug("#{@user.hashed_password}")
  end
  
  context "User database sandbox" do
    setup do
      #@user = Factory.create(:user)
    end
  end
end