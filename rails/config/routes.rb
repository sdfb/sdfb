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
  resources :relationships
  resources :groups
  resources :group_assignments
  resources :people
  resources :user_person_contribs
  resources :user_rel_contribs
  resources :home
  resources :user_group_contribs

  # Session management
  resources :sessions
  get "sign_in" => "sessions#new", :as => "sign_in"
  get "sign_out" => "sessions#destroy", :as => "sign_out"

  resources :users
  get 'password_resets/new'
  get "sign_up" => "users#new", :as => "sign_up"
end
