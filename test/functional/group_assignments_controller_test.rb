require 'test_helper'

class GroupAssignmentsControllerTest < ActionController::TestCase
  setup do
    @group_assignment = group_assignments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:group_assignments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group_assignment" do
    assert_difference('GroupAssignment.count') do
      post :create, group_assignment: { created_by: @group_assignment.created_by, group_id: @group_assignment.group_id, is_approved: @group_assignment.is_approved, person_id: @group_assignment.person_id }
    end

    assert_redirected_to group_assignment_path(assigns(:group_assignment))
  end

  test "should show group_assignment" do
    get :show, id: @group_assignment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @group_assignment
    assert_response :success
  end

  test "should update group_assignment" do
    put :update, id: @group_assignment, group_assignment: { created_by: @group_assignment.created_by, group_id: @group_assignment.group_id, is_approved: @group_assignment.is_approved, person_id: @group_assignment.person_id }
    assert_redirected_to group_assignment_path(assigns(:group_assignment))
  end

  test "should destroy group_assignment" do
    assert_difference('GroupAssignment.count', -1) do
      delete :destroy, id: @group_assignment
    end

    assert_redirected_to group_assignments_path
  end
end
