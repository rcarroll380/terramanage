require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "assigns a UUID primary key" do
    book = Book.create!(name: "Oak Street Properties")

    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/, book.id)
  end
end
