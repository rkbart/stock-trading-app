require "test_helper"

class SellsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sells_new_url
    assert_response :success
  end
end
