CurrencyTracker::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => "users/registrations", :sessions => "users/sessions"}
  root :to => "currencies#index"
  
  match 'countries/visited_over_time' => 'countries#visited_over_time', :via => :get
  match 'countries/visited_vs_notvisited' => 'countries#visited_vs_notvisited', :via => :get
  match 'countries_with_max_currency_value' => 'countries#countries_with_max_currency_value', :via => :get
  resources :countries, :except => [:new, :destroy]

  match 'currencies/collected_over_time' => 'currencies#collected_over_time', :via => :get
  match 'currencies/collected_vs_notcollected' => 'currencies#collected_vs_notcollected', :via => :get
  resources :currencies, :only => [:index, :show]

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
