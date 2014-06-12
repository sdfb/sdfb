require 'test_helper'

class UserGroupContribsControllerTest < ActionController::TestCase
  setup do
    @user_group_contrib = user_group_contribs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_group_contribs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_group_contrib" do
    assert_difference('UserGroupContrib.count') do
      post :create, user_group_contrib: { annotation: @user_group_contrib.annotation, bibliography: @user_group_contrib.bibliography, created_by: @user_group_contrib.created_by, group_id: @user_group_contrib.group_id, is_flagged: @user_group_contrib.is_flagged }
    end

    assert_redirected_to user_group_contrib_path(assigns(:user_group_contrib))
  end

  test "should show user_group_contrib" do
    get :show, id: @user_group_contrib
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_group_contrib
    assert_response :success
  end

  test "should update user_group_contrib" do
    put :update, id: @user_group_contrib, user_group_contrib: { annotation: @user_group_contrib.annotation, bibliography: @user_group_contrib.bibliography, created_by: @user_group_contrib.created_by, group_id: @user_group_contrib.group_id, is_flagged: @user_group_contrib.is_flagged }
    assert_redirected_to user_group_contrib_path(assigns(:user_group_contrib))
  end

  test "should destroy user_group_contrib" do
    assert_difference('UserGroupContrib.count', -1) do
      delete :destroy, id: @user_group_contrib
    end

    assert_redirected_to user_group_contribs_path
  end
end
