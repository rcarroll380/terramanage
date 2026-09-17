require "test_helper"

class CustomersControllerTest < ActionDispatch::IntegrationTest
  test "lists customers and their status" do
    get customers_url

    assert_response :success
    assert_select "h1", "Customers"
    assert_select "#entity_30000000-0000-4000-8000-000000000001", text: /Ryan Carroll.*Active/m
    assert_select "#entity_30000000-0000-4000-8000-000000000003", text: /Former Customer.*Inactive/m
    assert_select "#entity_30000000-0000-4000-8000-000000000002", count: 0
  end
end
