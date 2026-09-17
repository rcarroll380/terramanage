class AddActiveToEntities < ActiveRecord::Migration[8.1]
  def change
    add_column :entities, :active, :boolean, null: false, default: true
  end
end
