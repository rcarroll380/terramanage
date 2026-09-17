require "test_helper"

class VendorsControllerTest < ActionDispatch::IntegrationTest
  test "lists vendors and their status" do
    get vendors_url

    assert_response :success
    assert_select "h1", "Vendors"
    assert_select "#entity_30000000-0000-4000-8000-000000000002", text: /Acme Plumbing.*Active/m
    assert_select "#entity_30000000-0000-4000-8000-000000000001", count: 0
  end

  test "creates a vendor" do
    assert_difference("Entity.vendors.count") do
      post vendors_url, params: { entity: { name: "Acme Electric", active: true } }
    end

    vendor = Entity.order(:created_at).last
    assert_equal "vendor", vendor.entity_type
    assert_redirected_to vendors_url
  end

  test "updates a vendor" do
    patch vendor_url(entities(:plumber)), params: { entity: { name: "Acme Plumbing LLC", active: false } }

    assert_equal "Acme Plumbing LLC", entities(:plumber).reload.name
    assert_not entities(:plumber).active?
    assert_redirected_to vendors_url
  end
end
