require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "is a valid factory" do
    assert_valid Factory.create(:notification)
  end
  
  context "creating a basic notification" do
    setup do
      @notification = Factory.create(:notification)
    end
    
    should "have a time assigned to it" do
      assert_not_nil @notification.time
    end
    
    should "have nothing as the user" do
      assert_nil @notification.about_user
    end
    
    should "have normal as the default level" do
      assert @notification.level
      assert_equal "Normal", @notification.status
    end
    context "with a bad level" do
      setup do
        @notification.update_attributes(:level => 5)
      end
      
      should "not be valid" do
        assert_not_valid @notification
      end
    end
    context "with a user" do
      setup do
        @user = Factory.create(:user)
        @notification2 = Factory.create(:notification, :about_user => @user)
      end
      
      should "have a user associated with it" do
        assert_not_nil @notification2.about_user
        assert_equal @user.name, @notification2.get_user_name
      end
    end
  end
end
