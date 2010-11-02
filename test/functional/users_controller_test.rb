require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, :user => { }
    end
    assert_redirected_to user_path(assigns(:user))
  end
  
  test "should show user" do
    get :show, :id => user(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => user(:one).id
    assert_response :success
  end

  test "should update user" do
    put :update, :id => user(:one).id, :user => { }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, :id => user(:one).id
    end

    assert_redirected_to user_path
  end
end
