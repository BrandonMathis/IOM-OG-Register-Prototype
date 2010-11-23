require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  context "After login" do
    setup do
      user = Factory.create(:user)
      session[:user_id] = User.find(:all).first.user_id
    end
    
    should "get index" do
      get :index
      assert_response 200
      assert_not_nil assigns(:notifications)
    end
    
    should "get new" do
      get :new
      assert_response 200
    end
    
    should "create notifications" do
      assert_difference('Notification.count') do
        post :create, :notification => { }
      end

      assert_redirected_to notifications_path
    end
    
    context "with Notification in database" do
      setup do
        @notification = Factory.create(:notification)
      end
    
      should "show notifications" do
        get :show, :id => @notification._id
        assert_response :success
      end
    
      should "get edit" do
        get :edit, :id => @notification._id
        assert_response :success
      end
    
      should "update notifications" do
        put :update, :id => @notification._id, :notification => { }
        assert_redirected_to @notification
      end
    
      should "destroy notifications" do
        assert_difference('Notification.count', -1) do
          delete :destroy, :id => @notification._id
        end

        assert_redirected_to notifications_path
      end
    end
  end
end
