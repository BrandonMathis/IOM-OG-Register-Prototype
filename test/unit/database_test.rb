require 'test_helper'

class DatabaseTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "is valid factory" do
    assert Factory.create(:database)
  end
  context "User database sandbox" do
    setup do
      @user = Factory.create(:user)
    end
  end
  
  context "Adding Users to database" do
    setup do
      @database = Factory.create(:database)
      @database2 = Factory.create(:database)
      @user = Factory.create(:user)
      @user2 = Factory.create(:user)
      @database.add_user @user
      @database.add_user @user2
    end
    should "put database in users list of databases" do
      assert User.find_by_id(@user.user_id).databases.include?(@database._id)
      assert User.find_by_id(@user2.user_id).databases.include?(@database._id)
    end
    should "put user in database's list of users" do
      assert Database.find_by_id(@database._id).users.include?(@user.user_id)
      assert Database.find_by_id(@database._id).users.include?(@user2.user_id)
    end
    context "Then deleting database" do
      setup do
        @id = @database._id
        @database.delete
      end
      should "delete the database from the user's list of databases" do
        assert !@user.databases.include?(@id)
      end
    end
  end
end
