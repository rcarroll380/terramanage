class CreateEntities < ActiveRecord::Migration[8.1]
  def change
    create_table :entities, id: :string, limit: 36 do |t|
      t.string :entity_type, null: false
      t.string :name, null: false
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state, limit: 2
      t.string :postal_code, limit: 10

      t.timestamps
    end
  end
end
