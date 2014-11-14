require 'test_helper'

class RelationshipCategoriesControllerTest < ActionController::TestCase
  setup do
    @relationship_category = relationship_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:relationship_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create relationship_category" do
    assert_difference('RelationshipCategory.count') do
      post :create, relationship_category: { description: @relationship_category.description, name: @relationship_category.name }
    end

    assert_redirected_to relationship_category_path(assigns(:relationship_category))
  end

  test "should show relationship_category" do
    get :show, id: @relationship_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @relationship_category
    assert_response :success
  end

  test "should update relationship_category" do
    put :update, id: @relationship_category, relationship_category: { description: @relationship_category.description, name: @relationship_category.name }
    assert_redirected_to relationship_category_path(assigns(:relationship_category))
  end

  test "should destroy relationship_category" do
    assert_difference('RelationshipCategory.count', -1) do
      delete :destroy, id: @relationship_category
    end

    assert_redirected_to relationship_categories_path
  end
end
