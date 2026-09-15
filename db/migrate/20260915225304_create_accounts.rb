class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.references :book, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :accounts }
      t.integer :account_type, null: false
      t.string :name, null: false
      t.string :number, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :accounts, [ :book_id, :number ], unique: true
  end
end
