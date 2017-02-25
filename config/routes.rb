Rails.application.routes.draw do

	resources :users do
		member do
			get 'report', to: 'users#report'
			get 'inventory', to: 'users#inventory'
		end
	end

	resources :inventories do
		member do
			post 'add', to: 'inventories#add'
			post 'remove', to: 'inventories#remove'
		end
	end
end
