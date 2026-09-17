class Entity < ApplicationRecord
  enum :entity_type, { vendor: "vendor", customer: "customer" }

  validates :name, :entity_type, presence: true
end
