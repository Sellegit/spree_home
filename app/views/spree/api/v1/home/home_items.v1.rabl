object @home_item

attributes :id, :name, :position,:module_type, :url, :image_url

node do|home_item|
	if product = home_item.product
		{ :product_id => product.id, 
			:product_name => product.name, 
			:display_price =>  product.display_min_price,
			:primary_image_url => product.master.images.first.maybe.attachment.url(:compressed).just}
	end
end

node(:items, :if => lambda{ |home_item| home_item.children.frontend_items.present? }) do |t|
  t.children.map { |c| partial("spree/api/v1/home/home_items", object: c) }
end

 