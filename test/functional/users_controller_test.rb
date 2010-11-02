require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  context "After login" do
    setup do
      session[:user_id] = User.find(:all).first.user_id
    end
    
    should "get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:users)
    end

    should "get new" do
      get :new
      assert_response :success
    end
    
    should "create user" do
      name = Time.now.to_s
      pass = name + "123"
      assert_difference('User.count') do
        post :create, :user => {:name => name, :password_confirmation => pass, :password => pass }
      end
      assert_redirected_to users_url
    end
  
    should "show user" do
      get :show, :id => User.find(:all).first.id
      assert_response :success
    end

    should "get edit" do
      get :edit, :id => User.find(:all).first.id
      assert_response :success
    end

    should "update user" do
      put :update, :id => User.find(:all).first.id, :user => { }
      assert_redirected_to users_url
    end

    should "destroy user" do
      assert_difference('User.count', -1) do
        delete :destroy, :id => User.find(:all).first.id
      end

      assert_redirected_to users_url
    end
  end
end
