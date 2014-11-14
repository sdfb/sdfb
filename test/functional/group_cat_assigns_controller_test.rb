require 'test_helper'

class GroupCatAssignsControllerTest < ActionController::TestCase
  setup do
    @group_cat_assign = group_cat_assigns(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:group_cat_assigns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group_cat_assign" do
    assert_difference('GroupCatAssign.count') do
      post :create, group_cat_assign: { group_category_id: @group_cat_assign.group_category_id, group_id: @group_cat_assign.group_id }
    end

    assert_redirected_to group_cat_assign_path(assigns(:group_cat_assign))
  end

  test "should show group_cat_assign" do
    get :show, id: @group_cat_assign
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @group_cat_assign
    assert_response :success
  end

  test "should update group_cat_assign" do
    put :update, id: @group_cat_assign, group_cat_assign: { group_category_id: @group_cat_assign.group_category_id, group_id: @group_cat_assign.group_id }
    assert_redirected_to group_cat_assign_path(assigns(:group_cat_assign))
  end

  test "should destroy group_cat_assign" do
    assert_difference('GroupCatAssign.count', -1) do
      delete :destroy, id: @group_cat_assign
    end

    assert_redirected_to group_cat_assigns_path
  end
end
