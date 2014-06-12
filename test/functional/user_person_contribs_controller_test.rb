require 'test_helper'

class UserPersonContribsControllerTest < ActionController::TestCase
  setup do
    @user_person_contrib = user_person_contribs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_person_contribs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_person_contrib" do
    assert_difference('UserPersonContrib.count') do
      post :create, user_person_contrib: { annotation: @user_person_contrib.annotation, bibliography: @user_person_contrib.bibliography, created_by: @user_person_contrib.created_by, is_flagged: @user_person_contrib.is_flagged, person_id: @user_person_contrib.person_id }
    end

    assert_redirected_to user_person_contrib_path(assigns(:user_person_contrib))
  end

  test "should show user_person_contrib" do
    get :show, id: @user_person_contrib
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_person_contrib
    assert_response :success
  end

  test "should update user_person_contrib" do
    put :update, id: @user_person_contrib, user_person_contrib: { annotation: @user_person_contrib.annotation, bibliography: @user_person_contrib.bibliography, created_by: @user_person_contrib.created_by, is_flagged: @user_person_contrib.is_flagged, person_id: @user_person_contrib.person_id }
    assert_redirected_to user_person_contrib_path(assigns(:user_person_contrib))
  end

  test "should destroy user_person_contrib" do
    assert_difference('UserPersonContrib.count', -1) do
      delete :destroy, id: @user_person_contrib
    end

    assert_redirected_to user_person_contribs_path
  end
end
