class AddCategoryAccountToTransactions < ActiveRecord::Migration[8.1]
  def up
    add_column :transactions, :category_account_id, :string, limit: 36
    add_foreign_key :transactions, :accounts, column: :category_account_id
    execute "UPDATE transactions SET category_account_id = account_id"
    change_column_null :transactions, :category_account_id, false
    add_index :transactions, :category_account_id
  end

  def down
    remove_index :transactions, :category_account_id
    remove_foreign_key :transactions, column: :category_account_id
    remove_column :transactions, :category_account_id
  end
end
