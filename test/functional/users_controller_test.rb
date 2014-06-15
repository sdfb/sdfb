require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

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
      post :create, user: { about_description: @user.about_description, affiliation: @user.affiliation, email: @user.email, first_name: @user.first_name, is_active: @user.is_active, last_name: @user.last_name, password: @user.password, password_confirmation: @user.password_confirmation, password_hash: @user.password_hash, password_salt: @user.password_salt, user_type: @user.user_type }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user, user: { about_description: @user.about_description, affiliation: @user.affiliation, email: @user.email, first_name: @user.first_name, is_active: @user.is_active, last_name: @user.last_name, password: @user.password, password_confirmation: @user.password_confirmation, password_hash: @user.password_hash, password_salt: @user.password_salt, user_type: @user.user_type }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
