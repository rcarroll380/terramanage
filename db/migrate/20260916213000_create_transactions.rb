class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions, id: :string, limit: 36 do |t|
      t.references :book, type: :string, limit: 36, null: false, foreign_key: true
      t.date :date, null: false
      t.string :number
      t.references :entity, type: :string, limit: 36, null: false, foreign_key: true
      t.decimal :payment, precision: 12, scale: 2, null: false, default: 0
      t.decimal :deposit, precision: 12, scale: 2, null: false, default: 0
      t.decimal :balance, precision: 12, scale: 2, null: false, default: 0
      t.references :account, type: :string, limit: 36, null: false, foreign_key: true
      t.text :memo
      t.boolean :reconciled, null: false, default: false

      t.timestamps
    end

    add_index :transactions, [ :book_id, :date, :id ]
  end
end
