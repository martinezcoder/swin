Swin::Application.routes.draw do

  resources :facebook_lists, :path => "/facebook/lists" do
    member do
      post :activate
    end
  end
  resources :list_page_relationships, only: [:create, :destroy]

  match "/facebook", to: 'facebook#dashboard'
  match "/facebook/engage", to: 'facebook#engage'
  match "/facebook/size", to: 'facebook#size'
  match "/facebook/activity", to: 'facebook#activity'
  match "/facebook/growth", to: 'facebook#growth'
  match "/facebook/empty", to: 'facebook#empty'
  match "/facebook/dashboard", to: 'facebook#dashboard'

  # ADMIN PROTECTED
  match "/users/admin_query", to: 'users#admin_query'
  match "/pages/admin_query", to: 'pages#admin_query'
  match '/admin', to: 'static_pages#admin'
  

  resources :sessions, only: [:new, :destroy]
  resources :users, only: [:new, :create]
  resources :pages, :path => "/facebook", only: :show

  match '/signout', to: 'sessions#destroy', via: :delete

  match '/auth/:provider/callback', to: 'sessions#new'

  match '/youtube', to: 'static_pages#youtube'
  match '/twitter', to: 'static_pages#twitter'
  
  match '/about', to: 'site#about' 
  match '/search_engagement', to: 'site#search'

  root to: 'site#home'


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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
