require "test_helper"

class LanguagesControllerTest < ActionDispatch::IntegrationTest
  test "should get ruby" do
    get languages_ruby_url
    assert_response :success
  end

  test "should get python" do
    get languages_python_url
    assert_response :success
  end

  test "should get javascript" do
    get languages_javascript_url
    assert_response :success
  end
end
