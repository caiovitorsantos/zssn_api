Rails.application.routes.draw do

	get 'reports', to: 'users#reports'
	resources :users do
		member do
			get 'complaint', to: 'users#complaint'
			put 'set_location', to: 'users#set_location'
			get 'inventory', to: 'users#inventory'
		end
	end

	post 'exchange', to: 'inventories#exchange'
	# As duas rotas abixo estão fora do resources pois recebem parametros "id" compostos {:user_id e :kind} 
	get 'index', to: 'inventories#index'
	resources :inventories do
		member do
			post 'add', to: 'inventories#add'
			post 'remove', to: 'inventories#remove'
		end
	end
end
