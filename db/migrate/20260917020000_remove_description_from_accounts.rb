class RemoveDescriptionFromAccounts < ActiveRecord::Migration[8.1]
  def change
    remove_column :accounts, :description, :text
  end
end
