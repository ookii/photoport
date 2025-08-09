require_relative "boot"

require "rails"
require "active_model/railtie"
# require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"
require "active_support/parameter_filter"

Bundler.require(*Rails.groups)

module PhotoPort
  class Application < Rails::Application
    # Don't load full defaults since we don't use ActiveRecord/ActiveStorage
    # config.load_defaults 7.1
    
    # Configure only what we need for a minimal Rails app
    config.encoding = "utf-8"
    config.time_zone = 'UTC'

    # Skip views, helpers and assets when generating a new resource.
    config.generators do |g|
      g.skip_routes  false
      g.helper       false
      g.assets       false
      g.view_specs   false
      g.helper_specs false
      g.routing_specs false
      g.controller_specs false
    end

    # Autoload lib directory
    config.autoload_paths << Rails.root.join('app', 'lib')
    config.eager_load_paths << Rails.root.join('app', 'lib')

    # Enable serving of images
    config.public_file_server.enabled = true
    
    # Configure exceptions app
    config.exceptions_app = self.routes
    
    # Initialize logger early to prevent nil logger issues
    log_dir = Rails.root.join('log')
    Dir.mkdir(log_dir) unless Dir.exist?(log_dir)
    
    config.logger = ActiveSupport::Logger.new(Rails.root.join('log', "#{Rails.env}.log"))
    config.logger = ActiveSupport::TaggedLogging.new(config.logger)
    
    # Remove problematic Rails::Rack::Logger middleware that has nil logger
    config.middleware.delete Rails::Rack::Logger
  end
end