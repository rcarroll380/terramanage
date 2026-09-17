class Transaction < ApplicationRecord
  belongs_to :book
  belongs_to :account
  belongs_to :entity

  validates :date, :account, presence: true
  validates :payment, :deposit, :balance, numericality: true
  validate :account_belongs_to_book
  validate :entity_is_vendor_or_customer

  scope :ordered, -> { order(:date, :id) }

  def self.recalculate_balances!(book)
    running_balance = 0

    book.transactions.ordered.each do |transaction|
      running_balance += transaction.deposit.to_d - transaction.payment.to_d
      transaction.update_column(:balance, running_balance)
    end
  end

  private
    def account_belongs_to_book
      return if account.blank? || book.blank? || account.book_id == book_id

      errors.add(:account, "must belong to the same book")
    end

    def entity_is_vendor_or_customer
      return if entity.blank? || entity.vendor? || entity.customer?

      errors.add(:entity, "must be a vendor or customer")
    end
end
