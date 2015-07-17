Sdfb::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.

  config.eager_load = true
  config.assets.js_compressor = :uglifier

  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Don't care if the mailer can't send
  config.action_mailer.raise  _delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  #config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  #config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  #config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress 
  config.assets.enabled = true
  config.assets.compress = true
  config.serve_static_files = true
  config.assets.compile = true
  config.assets.digest = false
  config.action_dispatch.x_sendfile_header = ‘X-Accel-Redirect’
  # Expands the lines which load the assets
  config.assets.debug = false

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( jquery-2.1.1.min jquery-impromptu.min.js jquery-ui.min.js accordion.js autocomplete-rails.js bootstrap.min display.js insights.standalone.js script.js pace.js typeahead.js )

  # # Don't fallback to assets pipeline if a precompiled asset is missed
  # config.assets.compile = false

  # # Generate digests for assets URLs
  # config.assets.digest = true


  #Mail settings for SDFB2
  #ActionMailer::Base.smtp_settings = {
  #  :user_name => 'app35236337@heroku.com',
  #  :password => '3irsljgy5593',
  #  :domain => 'sdfb2.herokuapp.com',
  #  :address => 'smtp.sendgrid.net',
  #  :port => 587,
  #  :authentication => :plain,
  #  :enable_starttls_auto => true
  #}
#config.action_mailer.default_url_options = { :host =>  "sdfb2.herokuapp.com" }  

  ActionMailer::Base.smtp_settings = {
    :user_name => 'app32983575@heroku.com',
    :password => 'ivu6mhmu4416',
    :domain => 'sixdegfrancisbacon.herokuapp.com',
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
  }
  config.action_mailer.default_url_options = { :host =>  "sixdegfrancisbacon.herokuapp.com" }  

end
