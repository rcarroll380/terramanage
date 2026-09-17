require "application_system_test_case"

class AccountsTest < ApplicationSystemTestCase
  test "viewing the chart of accounts" do
    visit accounts_path

    assert_selector "h1", text: "Chart of accounts"
    assert_link "Rental Income"
    assert_link "Base Rent"
  end

  test "viewing the customer list" do
    visit customers_path

    assert_selector "h1", text: "Customers"
    assert_text "Ryan Carroll"
    assert_text "Active"
    assert_no_text "Acme Plumbing"
  end

  test "opening the new customer form" do
    visit customers_path
    click_link "New customer"

    assert_selector "h1", text: "New customer"
    assert_field "Customer name"
  end
end
