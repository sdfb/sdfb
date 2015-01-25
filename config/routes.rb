Sdfb::Application.routes.draw do
  get "about" => "static_pages#about", :as => "about"
	get "help" => "static_pages#help", :as => "help"
  get "tos" => "static_pages#tos", :as => "tos"
  resources :comments


  resources :relationship_types


  resources :rel_cat_assigns


  resources :relationship_categories


  resources :group_cat_assigns


  resources :group_categories


  resources :flags


  get "sign_in" => "sessions#new", :as => "sign_in"
  get "sign_out" => "sessions#destroy", :as => "sign_out"

  get "sign_up" => "users#new", :as => "sign_up"
  get "test" => "home#test", :as => "test"
  get "home/index"

  get "dashboard" => "users#dashboard", :as => "dashboard"

  # set the root
  root :to => "home#index"

  match '/people_search', :to => 'people#search'

  match '/group_search', :to => 'groups#search'

  match '/relationship_search', :to => 'relationships#search'
  
  resources :users
  
  
  resources :sessions


  resources :relationships do
    get :autocomplete_person_search_names_all, on: :collection
  end


  resources :groups


  resources :user_group_contribs


  resources :group_assignments


  resources :people


  resources :user_person_contribs do
    get :autocomplete_person_search_names_all, on: :collection
  end


  resources :user_rel_contribs do
    get :autocomplete_person_search_names_all, on: :collection
  end

  # Routing for people record export
  match '/export_groups' => 'groups#export_groups'

  # Routing for people record export
  match '/export_people' => 'people#export_people'

  # Routing for relationship record export
  get "export_relationships" => "relationships#export_relationships", :as => "export_relationships"
  match '/relationships_100000000_100020000' => 'relationships#export_rels_for_rels_100000000_100020000'
  match '/relationships_100020001_100040000' => 'relationships#export_rels_for_rels_100020001_100040000'
  match '/relationships_100040001_100060000' => 'relationships#export_rels_for_rels_100040001_100060000'
  match '/relationships_100060001_100080000' => 'relationships#export_rels_for_rels_100060001_100080000'
  match '/relationships_100080001_100100000' => 'relationships#export_rels_for_rels_100080001_100100000'
  match '/relationships_100100001_100120000' => 'relationships#export_rels_for_rels_100100001_100120000'
  match '/relationships_100120001_100140000' => 'relationships#export_rels_for_rels_100120001_100140000'
  match '/relationships_100140001_100160000' => 'relationships#export_rels_for_rels_100140001_100160000'
  match '/relationships_100160001_100180000' => 'relationships#export_rels_for_rels_100160001_100180000'
  match '/relationships_greater_than_100180000' => 'relationships#export_rels_for_rels_greater_than_100180000'

  # main resources  # The priority is based upon order of creation:
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
