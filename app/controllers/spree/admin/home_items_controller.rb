module Spree
  module Admin
		class HomeItemsController < ResourceController
			before_action :check_item, only: [:create]
			before_action :load_home, only: [:update, :create, :edit, :add_third]
			before_action :load_home_item, only: [:update, :add_product, :delete, :add_third]

			def edit
				@title = Spree::HomeItem::ITEM_MODULES_INVERT[params[:module_type].to_i].to_s.titleize
				render edit_partial
			end

			##创建二级的module
			def create
				item = Spree::HomeItem.new(item_param.merge({home_id: @home.id}))
				if item.module_type == 3 #taxon
					ActiveRecord::Base.transaction do
						item.save!
						items = []
						(1..4).each do|v|
							items << {parent_id: item.id, home_id: item.home_id, name: 'Taxon_children', will_order: v, module_type: 3}
						end	
						Spree::HomeItem.create!(items)
					end	
					render json: { status: true}	
				else
					if item.save
						render json: { status: true}
					else
						render json: { status: false, msg: item.errors.full_messages.join }
					end
				end	
				
			end
			
			def update
				pms  = update_params
				attachment = pms.delete :attachment

				if attachment
					ActiveRecord::Base.transaction do
						@home_item.update_attributes!(pms)
						Spree::HomeImage.create!(attachment: attachment, home_item: @home_item)
					end
					render json: { status: true, path: edit_admin_home_path(@home)}
				else
					if @home_item.update_attributes(pms)
						render json: { status: true, path: edit_admin_home_path(@home)}
					else
						render json: { status: false, msg: @home_item.errors.full_messages.join }
					end	
				end	
			end	

			## admin/homes/:home_id/home_items/:home_item_id/add
			###通用的添加第三级方法 will_order 取当前parent的children will_order 最大值加一
			def add_third
				order = @home_item.children.backend_items.maximum('will_order').to_i + 1
				name = "#{Spree::HomeItem::ITEM_MODULES_INVERT[@home_item.module_type].to_s.titleize} Child"
				home_item = Spree::HomeItem.new(parent_id: @home_item.id, will_order: order, home_id: params[:home_id], name: name, module_type: @home_item.module_type)
				if home_item.save
					render json: { status: true}
				else
					render json: { status: false, msg:  home_item.errors.full_messages.join}
				end
			end	

			def add_product
				will_order = @home_item.children.maximum('will_order').to_i + 1
				home_item = Spree::HomeItem.new(add_product_params.merge({will_order: will_order}))
				if result = home_item.save
					product = home_item.product
					render json: { status: result, 
													data: { id: home_item.id, will_order: home_item.will_order, name: product.name, state: product.available? ? 'Available' : 'Unavailable'} }
				else
					render json: { status: result, msg:  home_item.errors.full_messages.join}
				end		
				
			end
			def delete
				render json: { status: @home_item.update(deleted: true), msg:  @home_item.errors.full_messages.join}
			end
			def update_order
				ApplicationRecord.transaction do
					params[:positions].each do |id, index|
						Spree::HomeItem.find(id).update(will_order: index)
					end
				end

				respond_to do |format|
					format.js { render plain: 'Ok' }
				end
			end		
			private
			 def check_item
					@type = params[:item][:module_type].to_i
					unless @name = Spree::HomeItem::ITEM_MODULES_INVERT[@type]
						render json: { status: false, msg: I18n.t('home.error_add')} and return
					end	
					if @type == 5
						if Spree::HomeItem.find_by(parent_id: params[:item][:parent_id], module_type: 5, deleted: false)
							render json: { status: false, msg: I18n.t('home.error_add') } and return
						end	
					end	
			 end
			 def load_home
					@home = Spree::Home.find(params[:home_id])
			 end
			 def load_home_item
					@home_item = Spree::HomeItem.find(params[:home_item_id])
			 end
			  			 		 		
			 def item_param
				 { module_type: @type.to_s.titleize, name: @name, parent_id: params[:item][:parent_id]}
			 end
			 def update_params
					params.require(:home_item).permit(:url, :name, :attachment, :item_id)
			 end			 
			 def add_product_params
					params.require(:product).permit(:parent_id, :home_id, :item_id, :module_type)
			 end		
			 def edit_partial
					case params[:module_type].to_i
					when 1
						'edit_1'
					when 2
						'edit_2'
					when 3
						'edit_3'
					when 4
						'edit_4'
					when 5
					else
						'edit'
					end					
			 end			 	
		end	
	end
end		