class CreateSpreeHomeItems < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_home_items do |t|
			t.string 	:name
			t.string  :url
			t.integer :item_id
			t.integer :position,   :default => 0
			t.integer :will_order, :default => 0
			t.references :home
			t.integer :module_type
			t.integer :parent_id, :null => true, :index => true
      t.integer :lft, :null => false, :index => true
			t.integer :rgt, :null => false, :index => true
			t.integer :depth, :null => false, :default => 0
			t.boolean :active, :default => false
			t.boolean :deleted, :default => false
      t.timestamps
    end
  end
end
