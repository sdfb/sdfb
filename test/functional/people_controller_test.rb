require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  setup do
    @person = people(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:people)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create person" do
    assert_difference('Person.count') do
      post :create, person: { ext_birth_year: @person.ext_birth_year, created_by: @person.created_by, death_year: @person.death_year, first_name: @person.first_name, historical_significance: @person.historical_significance, is_approved: @person.is_approved, last_name: @person.last_name, original_id: @person.original_id }
    end

    assert_redirected_to person_path(assigns(:person))
  end

  test "should show person" do
    get :show, id: @person
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @person
    assert_response :success
  end

  test "should update person" do
    put :update, id: @person, person: { ext_birth_year: @person.ext_birth_year, created_by: @person.created_by, death_year: @person.death_year, first_name: @person.first_name, historical_significance: @person.historical_significance, is_approved: @person.is_approved, last_name: @person.last_name, original_id: @person.original_id }
    assert_redirected_to person_path(assigns(:person))
  end

  test "should destroy person" do
    assert_difference('Person.count', -1) do
      delete :destroy, id: @person
    end

    assert_redirected_to people_path
  end
end
