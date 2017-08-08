class CreateSpreeHomeImages < ActiveRecord::Migration[5.1]
  def change
		create_table :spree_home_images do |t|
			t.belongs_to :home_item, index: true
			t.attachment :attachment
			t.boolean :active, :default => false
			t.boolean :deleted, :default => false
      t.timestamps
    end
  end
end
