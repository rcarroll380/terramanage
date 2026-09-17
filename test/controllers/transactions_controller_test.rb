require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  test "lists transactions in a spreadsheet" do
    get transactions_url

    assert_response :success
    assert_select "h1", "Transactions"
    assert_select ".transaction-row", count: 3
    assert_select "#transaction_40000000-0000-4000-8000-000000000001"
    assert_select "#transaction_40000000-0000-4000-8000-000000000001 .transaction-balance", text: "$1,500.00"
    assert_select "input[name='transaction[reconciled]']", count: 0
    assert_select ".transaction-memo input[name='transaction[memo]']", count: 3
    assert_select ".payment-field input", count: 3
    assert_select ".deposit-field input", count: 3
    assert_select "select[name='transaction[category_account_id]']", count: 3
    assert_select "select[name='transaction[account_id]']", count: 0
    assert_select "input[type='hidden'][name='transaction[account_id]']", count: 3
    assert_select "input[type='hidden'][name='transaction[account_id]'][value='#{accounts(:rental_income).id}']", count: 3
    assert_select "input[type='submit']", count: 0
  end

  test "creates a transaction for the current book" do
    assert_difference("Transaction.count") do
      post transactions_url, params: {
        transaction: {
          date: "2026-01-03",
          entity_id: entities(:landlord).id,
          account_id: accounts(:rental_income).id,
          category_account_id: accounts(:base_rent).id,
          deposit: "500.00",
          payment: "0",
          memo: "February rent",
          reconciled: "0"
        }
      }
    end

    transaction = Transaction.order(:created_at).last
    assert_equal books(:my_rentals), transaction.book
    assert_equal 1750.to_d, transaction.balance
    assert_redirected_to transactions_url(account_id: accounts(:rental_income).id)
  end

  test "filters transactions by their main account" do
    get transactions_url(account_id: accounts(:rental_income).id)

    assert_response :success
    assert_select ".transaction-container", count: 3
    assert_select "#transaction_40000000-0000-4000-8000-000000000001", count: 1
    assert_select "#transaction_40000000-0000-4000-8000-000000000002", count: 1
  end

  test "updates a transaction inline" do
    patch transaction_url(transactions(:plumbing_payment)), params: {
      transaction: { payment: "300.00", entity_id: entities(:plumber).id, category_account_id: accounts(:base_rent).id }
    }

    assert_equal 300.to_d, transactions(:plumbing_payment).reload.payment
    assert_equal 1200.to_d, transactions(:plumbing_payment).balance
    assert_redirected_to transactions_url(account_id: accounts(:rental_income).id)
  end
end
