Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Don't care if the mailer can't send.
  # config.action_mailer.raise_delivery_errors = false
  # config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Debug mode disables concatenation and preprocessing of assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Use an evented file watcher to run tasks on changed files.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true
  
  # Configure logger to use standard log file
  config.log_level = :debug
  
  # Disable the problematic Rails::Rack::Logger middleware
  config.railties_order = [:main_app, :all]
  config.middleware.delete Rails::Rack::Logger
  
  # Allow all hosts for simple portfolio sites
  config.hosts.clear
end