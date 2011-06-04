require 'test_helper'

class DnssControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

end
