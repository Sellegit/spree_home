object @home_item

attributes :id, :name, :position,:module_type, :url, :image_url

node do|home_item|
	if (home_item.module_type == 4) && (product = home_item.product)  
		{ :product_id => product.id, 
			:product_name => product.name, 
			:display_price =>  product.display_min_price,
			:primary_image_url => product.master.images.first.maybe.attachment.url(:large).just}
	end
end
node do|home_item|
	if (home_item.module_type == 3) && (taxon = home_item.taxon)
		{
			:taxon_id => taxon.id,
			:taxon_parent_id => taxon.parent_id
		}
	end
end

node(:items, :if => lambda{ |home_item| home_item.children.frontend_items.present? }) do |t|
  t.children.map { |c| partial("spree/api/v1/home/home_items", object: c) }
end

 
