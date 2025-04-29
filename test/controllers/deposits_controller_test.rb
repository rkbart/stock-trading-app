require "test_helper"

class DepositsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get deposits_new_url
    assert_response :success
  end
end
