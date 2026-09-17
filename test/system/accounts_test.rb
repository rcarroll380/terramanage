require "application_system_test_case"

class AccountsTest < ApplicationSystemTestCase
  test "viewing the chart of accounts" do
    visit accounts_path

    within "nav[aria-label='Primary navigation']" do
      assert_no_link "Accounts"
      assert_link "Customers"
      assert_link "Vendors"
      assert_no_selector "a.is-active", text: "Accounts"
    end
    assert_selector "h1", text: "Chart of accounts"
    assert_link "Rental Income"
    assert_link "Base Rent"
  end

  test "viewing the customer list" do
    visit customers_path

    within "nav[aria-label='Primary navigation']" do
      assert_selector "a.is-active", text: "Customers"
    end
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

  test "opening a customer's edit form" do
    visit customers_path
    click_link "Ryan Carroll"

    assert_selector "h1", text: "Edit customer"
    assert_field "Customer name", with: "Ryan Carroll"
  end

  test "viewing and editing the vendor list" do
    visit vendors_path
    assert_selector "h1", text: "Vendors"
    assert_text "Acme Plumbing"
    assert_no_text "Ryan Carroll"

    click_link "Acme Plumbing"
    assert_selector "h1", text: "Edit vendor"
    assert_field "Vendor name", with: "Acme Plumbing"
  end

  test "creating a vendor stays on the vendor list" do
    visit new_vendor_path
    fill_in "Vendor name", with: "Acme Electric"
    click_button "Create vendor"

    assert_current_path vendors_path
    assert_selector "h1", text: "Vendors"
    assert_text "Acme Electric"
  end

  test "viewing the transactions spreadsheet" do
    visit transactions_path

    assert_selector "h1", text: "Transactions"
    assert_selector ".transaction-table-header", text: /DATE/
    assert_selector ".transaction-table-header", text: /BALANCE/
    assert_no_selector ".transaction-table-header", text: /ACCOUNT/
    assert_no_selector "select[name='transaction[account_id]']"
    assert_selector ".transaction-row", count: 3
  end
end
