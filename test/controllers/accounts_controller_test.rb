require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:repairs)
  end

  test "lists the chart of accounts" do
    get accounts_url

    assert_response :success
    assert_select "h1", "Chart of accounts"
    assert_select "a[href='#{transactions_path(account_id: accounts(:rental_income).id)}']", text: "Rental Income"
    assert_select "a", "Base Rent"
  end

  test "shows the new account form" do
    get new_account_url

    assert_response :success
    assert_select "form"
  end

  test "keeps working across requests in the same session" do
    get accounts_url
    assert_response :success

    get new_account_url
    assert_response :success
  end

  test "creates an account in the current book" do
    assert_difference("Account.count") do
      post accounts_url, params: {
        account: {
          account_type: "expense",
          active: true,
          name: "Insurance",
          number: "4100"
        }
      }
    end

    assert_equal books(:my_rentals), Account.last.book
    assert_redirected_to accounts_url
  end

  test "treats a blank parent as a top-level account" do
    assert_difference("Account.count") do
      post accounts_url, params: {
        account: {
          account_type: "expense",
          active: true,
          name: "Insurance",
          number: "4100",
          parent_id: ""
        }
      }
    end

    assert_nil Account.order(:created_at).last.parent_id
    assert_redirected_to accounts_url
  end

  test "shows an account" do
    get account_url(@account)
    assert_response :success
  end

  test "shows the edit form" do
    get edit_account_url(@account)
    assert_response :success
  end

  test "updates an account" do
    patch account_url(@account), params: { account: { name: "Repairs and maintenance" } }

    assert_equal "Repairs and maintenance", @account.reload.name
    assert_redirected_to accounts_url
  end

  test "deletes an account without subaccounts" do
    assert_difference("Account.count", -1) do
      delete account_url(@account)
    end

    assert_redirected_to accounts_url
  end

  test "does not accept a book id from the form" do
    other_book = Book.create!(name: "Other book")

    post accounts_url, params: {
      account: {
        book_id: other_book.id,
        account_type: "bank",
        active: true,
        name: "Checking",
        number: "1000"
      }
    }

    assert_equal books(:my_rentals), Account.find_by!(name: "Checking").book
  end
end
