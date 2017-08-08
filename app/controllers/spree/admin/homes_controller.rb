module Spree
  module Admin
		class HomesController < ResourceController

			def edit
				@item_modules = Spree::HomeItem::ITEM_MODULES
				@parent_item = @home.root
				@items =  @parent_item.children.backend_items
				super
			end
			
			def publish
				#deleted 为false 的删除掉  active:为false deleted为true 为即将发布的 根据will_order 设置 position 

				home_item = Spree::HomeItem.find(params[:id])
				ActiveRecord::Base.transaction do
					descendants = home_item.descendants
					will_deleted = descendants.where(deleted: true)
					will_deleted.destroy_all

					will_active = descendants.where(deleted: false)
					will_active.each do|item|
						item.update!({active: true, position: item.will_order})
						if image = item.image
							unless image.active
								image.update!(active: true)
								Spree::HomeImage.where("home_item_id = ? and id != ?", item.id, image.id).destroy_all
							end	
						end	
					end	
				end
				
				render json: { status: true}
			end	
				
		end	
	end
end		