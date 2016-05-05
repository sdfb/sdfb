Sdfb::Application.routes.draw do
  get 'password_resets/new'

  get "about" => "static_pages#about", :as => "about"
	get "help" => "static_pages#help", :as => "help"
  get "tos" => "static_pages#tos", :as => "tos"
  get "guide" => "static_pages#guide", :as => "guide"
  get "tutorial" => "static_pages#tutorial", :as => "tutorial"
  get "new_form_menu" => "static_pages#new_form_menu", :as => "new_form_menu"
  get "top_contributors" => "home#top_contributors", :as => "top_contributors"

  resources :comments
  resources :relationship_types
  resources :rel_cat_assigns
  resources :relationship_categories
  resources :group_cat_assigns
  resources :group_categories
  resources :flags
  resources :password_resets  


  get "sign_in" => "sessions#new", :as => "sign_in"
  get "sign_out" => "sessions#destroy", :as => "sign_out"

  get "sign_up" => "users#new", :as => "sign_up"
  get "test" => "home#test", :as => "test"
  get "home/index"

  get "my_contributions" => "users#my_contributions", :as => "my_contributions"
  get "all_inactive" => "users#all_inactive", :as => "all_inactive"
  get "all_unapproved" => "users#all_unapproved", :as => "all_unapproved"
  get "all_rejected" => "users#all_rejected", :as => "all_rejected"
  get "all_recent" => "users#all_recent", :as => "all_recent"

  get "new_person_form" => "people#new_2", :as => "new_person_form"
  get "new_relationship_form" => "relationships#new_2", :as => "new_relationship_form"
  get "reroute_relationship_form" => "relationships#reroute_relationship_form", :as => "reroute_relationship_form"
  get "new_existing_relationship_form" => "user_rel_contribs#new_2"
  get "new_new_relationship_form" => "relationships#new_new_relationship_form"
  get "new_group_form" => "groups#new_2", :as => "new_group_form"
  get "reroute_group_form" => "groups#reroute_group_form", :as => "reroute_group_form"
  get "relationship_create_2" => "relationships#create_2", :as => "relationship_create_2"

  # set the root
  root :to => "home#index"

  match '/people_search', :to => 'people#search', :via => [:get]

  match '/group_search', :to => 'groups#search', :via => [:get]

  match '/relationship_search', :to => 'relationships#search', :via => [:get]

  match '/people_membership', :to => 'people#membership', :via => [:get]
  match '/people_relationships', :to => 'people#relationships', :via => [:get]
  match '/people_notes', :to => 'people#notes', :via => [:get]

  match '/node_info', :to => 'home#update_node_info', :via => [:get]
  match '/network_info', :to => 'home#update_network_info', :via => [:get]

  resources :users
  
  resources :home do
    get :autocomplete_person_search_names_all, on: :collection
    get :autocomplete_group_name, on: :collection
  end

  
  resources :sessions


  resources :relationships do
    get :autocomplete_person_search_names_all, on: :collection
  end


  resources :groups do
    get :autocomplete_group_name, on: :collection
  end


  resources :user_group_contribs


  resources :group_assignments do
    get :autocomplete_person_search_names_all, on: :collection
  end

  # how to use autocomplete
  # this is an example of how autocomplete is setup
  # autocomplete also must be setup in the ability.rb file so people have access to it
  # set up is required in the forms as the option "<%= f.input :person_autocomplete, as: :autocomplete, url: autocomplete_person_search_names_all_group_assignments_path, input_html: { 'data-id-element' => '#group_assignment_person_id' }, label: "Person", placeholder: "name" %>"
  # must also be setup in the controller: autocomplete :person, :search_names_all, full: true, :extra_data => [:display_name, :ext_birth_year], :display_value => :autocomplete_name
  resources :people do
    get :autocomplete_person_search_names_all, on: :collection
  end

  resources :user_person_contribs do
    get :autocomplete_person_search_names_all, on: :collection
  end


  resources :user_rel_contribs do
    get :autocomplete_person_search_names_all, on: :collection
  end

  # how to export
  # update the controller with a method such as "def export_group_categories..." in the group_categories_controller
  # you need to make a new route for the page here
  # the route references the controller and the method such as 'group_categories#export_group_categories'
  # make a link to the export of the record type's index page such as index.html.erb for group_categories "<%=link_to 'Export Data', '/export_group_categories', :class => 'btn btn-primary'%>"
  # Routing for group category record export
  match '/export_group_categories' => 'group_categories#export_group_categories', :via => [:get]

  # Routing for group category assignment record export
  match '/export_group_cat_assigns' => 'group_cat_assigns#export_group_cat_assigns', :via => [:get]

  # Routing for relationship category assignment record export
  match '/export_rel_cat_assigns' => 'rel_cat_assigns#export_rel_cat_assigns', :via => [:get]

  # Routing for relationship category record export
  match '/export_rel_cats' => 'relationship_categories#export_rel_cats', :via => [:get]

  # Routing for relationship type record export
  match '/export_rel_types' => 'relationship_types#export_rel_types', :via => [:get]

  # Routing for user group contributions record export
  match '/export_group_notes' => 'user_group_contribs#export_group_notes', :via => [:get]

  # Routing for user person contributions record export
  match '/export_people_notes' => 'user_person_contribs#export_people_notes', :via => [:get]

  # Routing for user record export
  match '/export_users' => 'users#export_users', :via => [:get]

  # Routing for group assignments record export
  match '/export_group_assignments' => 'group_assignments#export_group_assignments', :via => [:get]

  # Routing for relationship type assignment record export
  get "export_rel_type_assigns" => "user_rel_contribs#export_rel_type_assigns", :as => "export_rel_type_assigns"
  match '/rel_type_assigns_00000_20000' => 'user_rel_contribs#export_rel_type_assigns_00000_20000', :via => [:get]
  match '/rel_type_assigns_20001_40000' => 'user_rel_contribs#export_rel_type_assigns_20001_40000', :via => [:get]
  match '/rel_type_assigns_40001_60000' => 'user_rel_contribs#export_rel_type_assigns_40001_60000', :via => [:get]
  match '/rel_type_assigns_60001_80000' => 'user_rel_contribs#export_rel_type_assigns_60001_80000', :via => [:get]
  match '/rel_type_assigns_80001_100000' => 'user_rel_contribs#export_rel_type_assigns_80001_100000', :via => [:get]
  match '/rel_type_assigns_100001_120000' => 'user_rel_contribs#export_rel_type_assigns_100001_120000', :via => [:get]
  match '/rel_type_assigns_120001_140000' => 'user_rel_contribs#export_rel_type_assigns_120001_140000', :via => [:get]
  match '/rel_type_assigns_140001_160000' => 'user_rel_contribs#export_rel_type_assigns_140001_160000', :via => [:get]
  match '/rel_type_assigns_160001_180000' => 'user_rel_contribs#export_rel_type_assigns_160001_180000', :via => [:get]
  match '/rel_type_assigns_greater_than_180000' => 'user_rel_contribs#export_rel_type_assigns_greater_than_180000', :via => [:get]

  # Routing for group record export
  match '/export_groups' => 'groups#export_groups', :via => [:get]

  # Routing for people record export
  match '/export_people' => 'people#export_people', :via => [:get]

  # Routing for relationship type/cat assign record export with relationship type and relationship category
  get "export_rel_cat_assign_list" => "rel_cat_assigns#export_rel_cat_assign_list",  :via => [:get], :as => "export_rel_cat_assign_list"

  # Routing for group category assign record export with group category
  get "export_group_cat_assign_list" => "group_cat_assigns#export_group_cat_assign_list", :via => [:get], :as => "export_group_cat_assign_list"

  # Routing for relationship record export
  get "export_relationships" => "relationships#export_relationships", :as => "export_relationships"
  match '/relationships_100000000_100020000' => 'relationships#export_rels_for_rels_100000000_100020000', :via => [:get]
  match '/relationships_100020001_100040000' => 'relationships#export_rels_for_rels_100020001_100040000', :via => [:get]
  match '/relationships_100040001_100060000' => 'relationships#export_rels_for_rels_100040001_100060000', :via => [:get]
  match '/relationships_100060001_100080000' => 'relationships#export_rels_for_rels_100060001_100080000', :via => [:get]
  match '/relationships_100080001_100100000' => 'relationships#export_rels_for_rels_100080001_100100000', :via => [:get]
  match '/relationships_100100001_100120000' => 'relationships#export_rels_for_rels_100100001_100120000', :via => [:get]
  match '/relationships_100120001_100140000' => 'relationships#export_rels_for_rels_100120001_100140000', :via => [:get]
  match '/relationships_100140001_100160000' => 'relationships#export_rels_for_rels_100140001_100160000', :via => [:get]
  match '/relationships_100160001_100180000' => 'relationships#export_rels_for_rels_100160001_100180000', :via => [:get]
  match '/relationships_greater_than_100180000' => 'relationships#export_rels_for_rels_greater_than_100180000', :via => [:get]

    # Routing for mass upload
  match '/large_data' => 'large_data#new', :via => [:get]

  match '/large_data/edit' => 'large_data#edit', :via => [:get]

  match '/large_data/edit' => 'large_data#edit', :via => [:post]

  match '/large_data/show' => 'large_data#show', :via => [:post]

  match '/large_data/confirm_people' => 'large_data#confirm_people', :via => [:post]

  match '/large_data/show' => 'large_data#show', :via => [:get]

  get 'large_data/download_csv'

  #match ':controller(/:action(/:id))', :via => [:get]
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
