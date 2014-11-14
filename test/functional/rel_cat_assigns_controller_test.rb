require 'test_helper'

class RelCatAssignsControllerTest < ActionController::TestCase
  setup do
    @rel_cat_assign = rel_cat_assigns(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rel_cat_assigns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rel_cat_assign" do
    assert_difference('RelCatAssign.count') do
      post :create, rel_cat_assign: { relationship_category_id: @rel_cat_assign.relationship_category_id, relationship_type_id: @rel_cat_assign.relationship_type_id }
    end

    assert_redirected_to rel_cat_assign_path(assigns(:rel_cat_assign))
  end

  test "should show rel_cat_assign" do
    get :show, id: @rel_cat_assign
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @rel_cat_assign
    assert_response :success
  end

  test "should update rel_cat_assign" do
    put :update, id: @rel_cat_assign, rel_cat_assign: { relationship_category_id: @rel_cat_assign.relationship_category_id, relationship_type_id: @rel_cat_assign.relationship_type_id }
    assert_redirected_to rel_cat_assign_path(assigns(:rel_cat_assign))
  end

  test "should destroy rel_cat_assign" do
    assert_difference('RelCatAssign.count', -1) do
      delete :destroy, id: @rel_cat_assign
    end

    assert_redirected_to rel_cat_assigns_path
  end
end
