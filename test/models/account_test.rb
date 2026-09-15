require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "supports a subaccount under an account of the same type" do
    account = Account.new(
      book: books(:my_rentals),
      parent: accounts(:rental_income),
      account_type: :income,
      name: "Late fees",
      number: "3020"
    )

    assert account.valid?
  end

  test "requires subaccounts to use their parent's type" do
    account = Account.new(
      book: books(:my_rentals),
      parent: accounts(:rental_income),
      account_type: :expense,
      name: "Invalid child",
      number: "9998"
    )

    assert_not account.valid?
    assert_includes account.errors[:parent], "must have the same account type"
  end

  test "prevents circular account hierarchies" do
    parent = accounts(:rental_income)
    parent.parent = accounts(:base_rent)

    assert_not parent.valid?
    assert_includes parent.errors[:parent], "cannot create a circular account hierarchy"
  end

  test "account numbers are unique within a book" do
    duplicate = accounts(:rental_income).dup

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:number], "has already been taken"
  end
end
