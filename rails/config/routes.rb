Sdfb::Application.routes.draw do

  # set the root
  root :to => "home#index"

  # API Routes
  defaults format: :json, via: [:get] do
    get  'api/people'
    get  'api/users'
    get  'api/relationships'
    get  'api/groups'
    get  'api/network'
    get  'api/groups/network', action: :group_network, controller: :api
    get  'api/typeahead'
    get  'api/curate/:type', action: :curate, controller: :api
    post 'api/edit_user'
    post 'api/new_user'
    post 'api/write'
    post 'api/sign_in', action: :create, controller: :sessions
    post 'api/sign_out', action: :destroy, controller: :sessions
    post 'api/request_password_reset', action: :create, controller: :password_resets
    post 'api/password_reset', action: :update, controller: :password_resets

  end

  # Static Pages
  get "about" => "static_pages#about", :as => "about"
  get "team" => "static_pages#team", :as => "team"
  get "help" => "static_pages#help", :as => "help"
  get "tos" => "static_pages#tos", :as => "tos"
  get "guide" => "static_pages#guide", :as => "guide"
  get "tutorial" => "static_pages#tutorial", :as => "tutorial"
  get "new_form_menu" => "static_pages#new_form_menu", :as => "new_form_menu"
  
  resources :relationship_types
  resources :rel_cat_assigns
  resources :relationship_categories
  resources :group_cat_assigns
  resources :group_categories
  resources :password_resets  

  # Session management
  resources :sessions
  get "sign_in" => "sessions#new", :as => "sign_in"
  
  get "sign_out" => "sessions#destroy", :as => "sign_out"

  get "new_person_form" => "people#new_2", :as => "new_person_form"
  post "create_new_person_form" => "people#create_2", :as => "create_new_person_form"
  
  get "new_relationship_form" => "relationships#new_2", :as => "new_relationship_form"
  get "reroute_relationship_form" => "relationships#reroute_relationship_form", :as => "reroute_relationship_form"
  get "new_existing_relationship_form" => "user_rel_contribs#new_2"
  get "new_new_relationship_form" => "relationships#new_new_relationship_form"
  get "new_group_form" => "groups#new_2", :as => "new_group_form"
  get "new_new_group_form" => "groups#new_3"
  get "reroute_group_form" => "groups#reroute_group_form", :as => "reroute_group_form"
  get "group_create_2" => "groups#create_2"
  get "group_add_person" => "group_assignments#new_2"
  post "group_add_person_create" => "group_assignments#create_2"
  post "relationship_create_2" => "relationships#create_2", :as => "relationship_create_2"
  post "user_rel_contribs_create_2" => "user_rel_contribs#create_2"



  resources :home do
    get :autocomplete_person_search_names_all, on: :collection
    get :autocomplete_group_name, on: :collection
  end
  match '/people_search', :to => 'people#search', :via => [:get]
  match '/group_search', :to => 'groups#search', :via => [:get]
  match '/relationship_search', :to => 'relationships#search', :via => [:get]

  resources :relationships do
    get :autocomplete_person_search_names_all, on: :collection
  end

  resources :groups do
    get :autocomplete_group_name, on: :collection
  end
  resources :group_assignments do
    get :autocomplete_person_search_names_all, on: :collection
  end
  resources :people do
    get :autocomplete_person_search_names_all, on: :collection
  end

  resources :user_person_contribs do
    get :autocomplete_person_search_names_all, on: :collection
  end

  resources :user_rel_contribs do
    get :autocomplete_person_search_names_all, on: :collection
  end



  match '/people_membership', :to => 'people#membership', :via => [:get]
  match '/people_relationships', :to => 'people#relationships', :via => [:get]
  match '/people_notes', :to => 'people#notes', :via => [:get]

  match '/node_info', :to => 'home#update_node_info', :via => [:get]
  match '/network_info', :to => 'home#update_network_info', :via => [:get]

  resources :users
  get 'password_resets/new'
  get "sign_up" => "users#new", :as => "sign_up"
  get "my_contributions" => "users#my_contributions", :as => "my_contributions"
  get "all_inactive" => "users#all_inactive", :as => "all_inactive"
  get "all_unapproved" => "users#all_unapproved", :as => "all_unapproved"
  get "all_rejected" => "users#all_rejected", :as => "all_rejected"
  get "all_recent" => "users#all_recent", :as => "all_recent"

  
  resources :user_group_contribs




  # how to use autocomplete
  # this is an example of how autocomplete is setup
  # autocomplete also must be setup in the ability.rb file so people have access to it
  # set up is required in the forms as the option "<%= f.input :person_autocomplete, as: :autocomplete, url: autocomplete_person_search_names_all_group_assignments_path, input_html: { 'data-id-element' => '#group_assignment_person_id' }, label: "Person", placeholder: "name" %>"
  # must also be setup in the controller: autocomplete :person, :search_names_all, full: true, :extra_data => [:display_name, :ext_birth_year], :display_value => :autocomplete_name


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

end
