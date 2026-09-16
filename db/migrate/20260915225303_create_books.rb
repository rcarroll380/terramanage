class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books, id: :string, limit: 36 do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
