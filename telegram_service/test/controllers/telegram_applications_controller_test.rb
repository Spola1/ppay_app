require "test_helper"

class TelegramApplicationsControllerTest < ActionDispatch::IntegrationTest
  test "should get create_in_microservice" do
    get telegram_applications_create_in_microservice_url
    assert_response :success
  end
end
