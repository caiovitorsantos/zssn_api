class CreateInventories < ActiveRecord::Migration[5.0]
  def change
    create_table :inventories do |t|
      t.references :user, foreign_key: true
      t.integer :kind
      t.integer :amount

      t.timestamps
    end
  end
end
