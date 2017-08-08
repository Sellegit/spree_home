if defined? Spree::Api
	module Spree
		module Api
			module V1
				class HomeController < Spree::Api::BaseController
					skip_before_action :authenticate_user, only: [:index]
					skip_before_action :load_user, only: [:index]
					skip_before_action :load_user_roles, only: [:index]
					skip_before_action :authorize_for_order, only: [:index]
					
				
					def index
						@home_items = 	Spree::Home.find_by(name: 'APP')&.root&.children.frontend_items
					end
				end		
			end
		end
	end
end