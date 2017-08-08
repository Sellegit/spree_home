Spree::Core::Engine.add_routes do
	# Add your extension routes here
	namespace :admin, path: Spree.admin_path do
		resources :homes, only: [:index, :edit] do
			member do
				post 'publish'
			end
			collection do
				post 'home_items/update_order' => 'home_items#update_order'
			end	
			resources :home_items do
				post 'add' => 'home_items#add_third'
				post 'update'
				post 'add_product'
				post 'delete'
			end	
		end
	end	
	namespace :api, defaults: { format: 'json' } do
		namespace :v1 do
			get 'home' => 'home#index'
		end
	end			
end
