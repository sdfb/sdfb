require 'test_helper'

class RelationshipTypesControllerTest < ActionController::TestCase
  setup do
    @relationship_type = relationship_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:relationship_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create relationship_type" do
    assert_difference('RelationshipType.count') do
      post :create, relationship_type: { default_rel_category: @relationship_type.default_rel_category, description: @relationship_type.description, is_active: @relationship_type.is_active, name: @relationship_type.name, relationship_type_inverse_id: @relationship_type.relationship_type_inverse_id }
    end

    assert_redirected_to relationship_type_path(assigns(:relationship_type))
  end

  test "should show relationship_type" do
    get :show, id: @relationship_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @relationship_type
    assert_response :success
  end

  test "should update relationship_type" do
    put :update, id: @relationship_type, relationship_type: { default_rel_category: @relationship_type.default_rel_category, description: @relationship_type.description, is_active: @relationship_type.is_active, name: @relationship_type.name, relationship_type_inverse_id: @relationship_type.relationship_type_inverse_id }
    assert_redirected_to relationship_type_path(assigns(:relationship_type))
  end

  test "should destroy relationship_type" do
    assert_difference('RelationshipType.count', -1) do
      delete :destroy, id: @relationship_type
    end

    assert_redirected_to relationship_types_path
  end
end
