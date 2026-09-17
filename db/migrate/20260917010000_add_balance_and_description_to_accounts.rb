class AddBalanceAndDescriptionToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :balance, :decimal, precision: 12, scale: 2, null: false, default: 0
    add_column :accounts, :description, :text
  end
end
