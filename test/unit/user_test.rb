require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "Is a valid factory" do
    @user = Factory.create(:user)
  end
  context "User with attached database" do
    setup do
      @user = Factory.create(:user)
      @db = Factory.create(:database)
      @user.update_attributes(:working_db => @db)
    end
    should "clear db from working_db uppon deletion" do
      assert_equal @db.name + "_test", ActiveRegistry.find_database(@user.user_id)
      @db.delete
      assert_equal CCOM_DATABASE, ActiveRegistry.find_database(@user.user_id)
    end
  end
end