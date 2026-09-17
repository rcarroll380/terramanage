require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  test "requires an entity" do
    transaction = Transaction.new(book: books(:my_rentals), account: accounts(:rental_income), category_account: accounts(:rental_income), date: Date.current)

    assert_not transaction.valid?
    assert_includes transaction.errors[:entity], "must exist"
  end

  test "requires a category account" do
    transaction = Transaction.new(book: books(:my_rentals), account: accounts(:rental_income), entity: entities(:landlord), date: Date.current)

    assert_not transaction.valid?
    assert_includes transaction.errors[:category_account], "must exist"
  end

  test "calculates running balances in date order" do
    Transaction.recalculate_balances!(books(:my_rentals))

    assert_equal 1500.to_d, transactions(:rent_deposit).reload.balance
    assert_equal 1250.to_d, transactions(:plumbing_payment).reload.balance
  end
end
