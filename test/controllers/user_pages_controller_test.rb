require "test_helper"

class UserPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_pages_index_url
    assert_response :success
  end

  test "should get new" do
    get user_pages_new_url
    assert_response :success
  end

  test "should get create" do
    get user_pages_create_url
    assert_response :success
  end

  test "should get show" do
    get user_pages_show_url
    assert_response :success
  end

  test "should get download" do
    get user_pages_download_url
    assert_response :success
  end

  test "should get upload" do
    get user_pages_upload_url
    assert_response :success
  end
end
