class Entity < ApplicationRecord
  enum :entity_type, { vendor: "vendor", customer: "customer" }

  scope :customers, -> { where(entity_type: :customer) }
  scope :vendors, -> { where(entity_type: :vendor) }

  validates :name, :entity_type, presence: true
end
