class CreateSpreeHomes < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_homes do |t|
			t.string  :name
			t.integer :position
      t.timestamps
    end
  end
end
