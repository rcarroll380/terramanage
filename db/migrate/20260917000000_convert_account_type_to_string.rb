class ConvertAccountTypeToString < ActiveRecord::Migration[8.1]
  def up
    rename_column :accounts, :account_type, :legacy_account_type
    add_column :accounts, :account_type, :string

    execute <<~SQL
      UPDATE accounts
      SET account_type = CASE legacy_account_type
        WHEN 0 THEN 'bank'
        WHEN 1 THEN 'income'
        WHEN 2 THEN 'expense'
        WHEN 3 THEN 'credit_card'
      END
    SQL

    change_column_null :accounts, :account_type, false
    remove_column :accounts, :legacy_account_type
  end

  def down
    rename_column :accounts, :account_type, :string_account_type
    add_column :accounts, :account_type, :integer

    execute <<~SQL
      UPDATE accounts
      SET account_type = CASE string_account_type
        WHEN 'bank' THEN 0
        WHEN 'income' THEN 1
        WHEN 'expense' THEN 2
        WHEN 'credit_card' THEN 3
      END
    SQL

    change_column_null :accounts, :account_type, false
    remove_column :accounts, :string_account_type
  end
end
