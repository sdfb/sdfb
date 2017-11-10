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

end
