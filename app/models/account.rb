class Account < ApplicationRecord
  belongs_to :book
  belongs_to :parent, class_name: "Account", optional: true, inverse_of: :subaccounts
  has_many :subaccounts,
    -> { order(:number, :name) },
    class_name: "Account",
    foreign_key: :parent_id,
    inverse_of: :parent,
    dependent: :restrict_with_error

  enum :account_type, {
    bank: 0,
    income: 1,
    expense: 2,
    credit_card: 3
  }

  validates :name, :number, :account_type, presence: true
  validates :number, uniqueness: { scope: :book_id }
  validate :parent_belongs_to_same_book
  validate :parent_has_same_type
  validate :parent_does_not_create_cycle
  validate :subaccounts_have_same_type

  scope :ordered, -> { order(:number, :name) }
  scope :top_level, -> { where(parent_id: nil) }

  def type_name
    account_type.humanize
  end

  private
    def parent_belongs_to_same_book
      return if parent.blank? || parent.book_id == book_id

      errors.add(:parent, "must belong to the same book")
    end

    def parent_has_same_type
      return if parent.blank? || parent.account_type == account_type

      errors.add(:parent, "must have the same account type")
    end

    def parent_does_not_create_cycle
      ancestor = parent

      while ancestor.present?
        if ancestor == self
          errors.add(:parent, "cannot create a circular account hierarchy")
          break
        end

        ancestor = ancestor.parent
      end
    end

    def subaccounts_have_same_type
      return unless will_save_change_to_account_type? && subaccounts.where.not(account_type: self.class.account_types[account_type]).exists?

      errors.add(:account_type, "must match existing subaccounts")
    end
end
