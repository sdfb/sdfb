require 'test_helper'

class FlagsControllerTest < ActionController::TestCase
  setup do
    @flag = flags(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:flags)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create flag" do
    assert_difference('Flag.count') do
      post :create, flag: { assoc_object_id: @flag.assoc_object_id, assoc_object_type: @flag.assoc_object_type, created_by: @flag.created_by, flag_description: @flag.flag_description, flag_type: @flag.flag_type, resolved_at: @flag.resolved_at, resolved_by: @flag.resolved_by }
    end

    assert_redirected_to flag_path(assigns(:flag))
  end

  test "should show flag" do
    get :show, id: @flag
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @flag
    assert_response :success
  end

  test "should update flag" do
    put :update, id: @flag, flag: { assoc_object_id: @flag.assoc_object_id, assoc_object_type: @flag.assoc_object_type, created_by: @flag.created_by, flag_description: @flag.flag_description, flag_type: @flag.flag_type, resolved_at: @flag.resolved_at, resolved_by: @flag.resolved_by }
    assert_redirected_to flag_path(assigns(:flag))
  end

  test "should destroy flag" do
    assert_difference('Flag.count', -1) do
      delete :destroy, id: @flag
    end

    assert_redirected_to flags_path
  end
end
