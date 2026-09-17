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

  test "shows the new customer form" do
    get new_customer_url

    assert_response :success
    assert_select "h1", "New customer"
    assert_select "form"
  end

  test "creates a customer with an optional address" do
    assert_difference("Entity.customers.count") do
      post customers_url, params: {
        entity: {
          name: "New Resident",
          address_line1: "456 Oak Avenue",
          city: "Lafayette",
          state: "IN",
          postal_code: "47905",
          active: true
        }
      }
    end

    customer = Entity.order(:created_at).last
    assert_equal "customer", customer.entity_type
    assert_equal "456 Oak Avenue", customer.address_line1
    assert_redirected_to customers_url
  end
end
