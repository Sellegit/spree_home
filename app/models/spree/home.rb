module Spree
	class Home < Spree::Base
		acts_as_list

    validates :name, presence: true, uniqueness: { case_sensitive: false }

    has_many :home_items,  -> {order(position: :asc)}, inverse_of: :home
    has_one :root, -> { where parent_id: nil }, class_name: "Spree::HomeItem", dependent: :destroy

    after_create :set_root
    after_save :set_root_home_item_name

    default_scope { order("#{self.table_name}.position, #{self.table_name}.created_at") }

    private
      def set_root
        self.root ||= HomeItem.create!(home_id: id, name: name)
      end

      def set_root_home_item_name
        root.update_attributes(name: name)
      end
	end	
end