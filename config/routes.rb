Rails.application.routes.draw do

  # get 'inventories/index'

  # get 'inventories/create'

  # get 'inventories/show'

  # get 'inventories/update'

  # get 'inventories/delete'
  post 'exchange', to: 'inventories#exchange'

  resources :inventories do
  	member do	
  		post 'add', to: 'inventories#add'
  		post 'remove', to: 'inventories#remove'
  	end
  end

   resources :users do
   	member do
   		get 'report', to: 'users#report'
   		get 'inventory', to: 'users#inventory'
   	end
   end
end
