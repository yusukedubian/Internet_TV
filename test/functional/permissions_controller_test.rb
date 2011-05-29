require 'test_helper'

class PermissionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:permissions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_permission
    assert_difference('Permission.count') do
      post :create, :permission => { }
    end

    assert_redirected_to permission_path(assigns(:permission))
  end

  def test_should_show_permission
    get :show, :id => permissions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => permissions(:one).id
    assert_response :success
  end

  def test_should_update_permission
    put :update, :id => permissions(:one).id, :permission => { }
    assert_redirected_to permission_path(assigns(:permission))
  end

  def test_should_destroy_permission
    assert_difference('Permission.count', -1) do
      delete :destroy, :id => permissions(:one).id
    end

    assert_redirected_to permissions_path
  end
end
