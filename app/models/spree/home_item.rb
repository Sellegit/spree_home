module Spree
	class HomeItem < Spree::Base

		acts_as_nested_set dependent: :destroy
		belongs_to :home, class_name: 'Spree::Home', inverse_of: :home_items

		scope :backend_items,  -> {where({deleted: false}).reorder(will_order: :asc)}
		scope :frontend_items,  -> {where({active: true}).reorder(position: :asc)}

		has_many :home_images, dependent: :destroy
		belongs_to :product, :class_name => "Spree::Product", :foreign_key =>"item_id"
		belongs_to :taxon, :class_name => "Spree::Taxon", :foreign_key =>"item_id"

		before_create :reorder_item_module

		ITEM_MODULES = { 
			:top_banner => 1, 
			:carousel => 2, 
			:taxon => 3, 
			:featured_products => 4, 
			:new_arrivals_feed => 5
		}

		ITEM_MODULES_INVERT = ITEM_MODULES.invert

		def image
			Spree::HomeImage.where("home_item_id = ? and active =?", self.id, false).order('updated_at Desc').take || Spree::HomeImage.where("home_item_id = ? and active =?", self.id, true).take
		end

		attr_accessor :image_url

		def image_url
			image = Spree::HomeImage.where("home_item_id = ? and active =?", self.id, true).order('updated_at Desc').take
			if image
				case self.module_type
				when 1
					image&.attachment&.url(:carousel)
				when 2
					image&.attachment&.url(:top_banner)
				when 3
					image&.attachment&.url(:taxon)
				end
			end	
		end

		def top_banner_image_url
			image&.attachment&.url(:top_banner)
		end
		def carousel_image_url
			image&.attachment&.url(:carousel)
		end	
		def taxon_image_url
			image&.attachment&.url(:taxon)
		end		
		def backend_product_items
			self.children.where({deleted: false}).reorder(will_order: :asc)
		end	

		private
			def reorder_item_module
				parent = self.parent
				if parent&.depth == 0
					siblings = parent.children.backend_items
					module_types = siblings.map(&:module_type)
					if module_types.include?(5)
						mt5 = siblings.where(module_type: 5).take
						will_order = mt5.will_order
						mt5.update(will_order: will_order + 1)
						self.will_order = will_order
					else
						self.will_order = siblings.map(&:will_order).max.to_i + 1
					end	 
				end	
			end	
	end	
end