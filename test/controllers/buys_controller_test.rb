require "test_helper"

class BuysControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get buys_new_url
    assert_response :success
  end
end
