source 'https://rubygems.org'
ruby '2.2.1'

# Native Rails gems — (These are required).
gem 'rails', '4.1.8'
gem 'railties', '4.1.8'
gem 'activemodel', '4.1.8'
gem 'rails-observers'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'
gem 'protected_attributes'

# Database Gems
gem 'pg'

# Webserver Gems
gem 'puma'
gem 'newrelic_rpm'
gem 'rails_12factor'

# Presentation Helper Libraries
gem 'will_paginate'
gem 'sass-rails'
gem 'simple_form'

# Front-end helpers
gem 'jquery-rails'
gem 'therubyracer', :platforms => :ruby
gem 'uglifier', '>= 1.0.3'
gem 'rails3-jquery-autocomplete'
gem 'jquery-turbolinks'
gem "twitter-bootstrap-rails", '2.1.7'

# API helpers
gem "jbuilder"
gem "yajl-ruby"

# Backend Helpers
gem 'cancan'
gem "carrierwave"
gem 'bcrypt', :require => "bcrypt"

group :production do
  gem 'rack-timeout'
end

group :development do
  gem 'binding_of_caller'
  gem 'better_errors'
  gem 'foreman'
  gem "brakeman", :require => false
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'rspec'
  gem 'database_cleaner'
  gem 'cucumber-api', require: false
  gem "json-schema"
end

group :development, :test do
  gem 'pry'
end
