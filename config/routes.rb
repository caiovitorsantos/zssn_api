Rails.application.routes.draw do

   resources :users do
   	member do
   		get 'report', to: 'users#report'
   		get 'inventory', to: 'users#inventory'
   	end
   end
end
