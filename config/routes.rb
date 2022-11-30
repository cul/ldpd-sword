Rails.application.routes.draw do
  root 'deposits#index'
  devise_for :users
  resources :users
  # get 'sword/deposit'
  # get 'sword/deposit/:collection_slug' => 'sword#deposit'
  post 'sword/deposit/:collection_slug' => 'sword#deposit'
  get 'sword/deposit/:collection_slug' => 'sword#service_document'
  get 'sword/service_document' => 'sword#service_document'
  get 'sword/service-document' => 'sword#service_document'
  get 'sword/servicedocument' => 'sword#service_document'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  resources :collections
  resources :depositors do
    member do
      get 'edit_permissions', action: 'edit_permissions', as: 'edit_permissions'
      # get 'update_permissions', action: 'update_permissions', as: 'update_permissions'
      post 'remove_permission', action: 'remove_permission', as: 'remove_permission'
      post 'add_permission', action: 'add_permission', as: 'add_permission'
    end
  end
  resources :deposits
  resources :packages

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
