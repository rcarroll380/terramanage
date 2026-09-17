require "test_helper"

class EntityTest < ActiveSupport::TestCase
  test "assigns a UUID primary key" do
    entity = Entity.create!(entity_type: :customer, name: "Oak Street Properties")

    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/, entity.id)
  end

  test "requires a name" do
    entity = Entity.new(entity_type: :customer)

    assert_not entity.valid?
    assert_includes entity.errors[:name], "can't be blank"
  end

  test "requires a vendor or customer type" do
    entity = Entity.new(name: "Oak Street Properties")

    assert_not entity.valid?
    assert_includes entity.errors[:entity_type], "can't be blank"
  end

  test "rejects unsupported entity types" do
    assert_raises(ArgumentError) do
      Entity.new(entity_type: "partner", name: "Oak Street Properties")
    end
  end

  test "allows an entity without an address" do
    entity = entities(:plumber)

    assert entity.valid?
    assert entity.vendor?
    assert_nil entity.address_line1
    assert_nil entity.state
  end

  test "stores an optional US address" do
    entity = entities(:landlord)

    assert entity.customer?
    assert_equal "123 Main Street", entity.address_line1
    assert_equal "Lafayette", entity.city
    assert_equal "IN", entity.state
    assert_equal "47901", entity.postal_code
  end
end
