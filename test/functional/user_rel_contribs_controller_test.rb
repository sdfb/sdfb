require 'test_helper'

class UserRelContribsControllerTest < ActionController::TestCase
  setup do
    @user_rel_contrib = user_rel_contribs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_rel_contribs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_rel_contrib" do
    assert_difference('UserRelContrib.count') do
      post :create, user_rel_contrib: { annotation: @user_rel_contrib.annotation, bibliography: @user_rel_contrib.bibliography, confidence_type: @user_rel_contrib.confidence_type, created_by: @user_rel_contrib.created_by, is_flagged: @user_rel_contrib.is_flagged, relationship_id: @user_rel_contrib.relationship_id, relationship_type: @user_rel_contrib.relationship_type }
    end

    assert_redirected_to user_rel_contrib_path(assigns(:user_rel_contrib))
  end

  test "should show user_rel_contrib" do
    get :show, id: @user_rel_contrib
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_rel_contrib
    assert_response :success
  end

  test "should update user_rel_contrib" do
    put :update, id: @user_rel_contrib, user_rel_contrib: { annotation: @user_rel_contrib.annotation, bibliography: @user_rel_contrib.bibliography, confidence_type: @user_rel_contrib.confidence_type, created_by: @user_rel_contrib.created_by, is_flagged: @user_rel_contrib.is_flagged, relationship_id: @user_rel_contrib.relationship_id, relationship_type: @user_rel_contrib.relationship_type }
    assert_redirected_to user_rel_contrib_path(assigns(:user_rel_contrib))
  end

  test "should destroy user_rel_contrib" do
    assert_difference('UserRelContrib.count', -1) do
      delete :destroy, id: @user_rel_contrib
    end

    assert_redirected_to user_rel_contribs_path
  end
end
