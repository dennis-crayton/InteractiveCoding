require "test_helper"

class CodeControllerTest < ActionDispatch::IntegrationTest
  test "should get run" do
    get code_run_url
    assert_response :success
  end
end
