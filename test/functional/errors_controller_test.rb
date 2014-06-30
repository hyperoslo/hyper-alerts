require 'test_helper'

class ErrorsControllerTest < ActionController::TestCase
  test "should get not_found" do
    get :not_found
    assert_response :not_found
  end

  test "should get internal_server_error" do
    get :internal_server_error
    assert_response :internal_server_error
  end
end
