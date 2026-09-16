class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  attribute :id, :string, default: -> { SecureRandom.uuid }
end
