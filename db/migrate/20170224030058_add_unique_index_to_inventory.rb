class AddUniqueIndexToInventory < ActiveRecord::Migration[5.0]
  def change
  	add_index :inventories, [:user_id, :kind], unique: true
  end
end
