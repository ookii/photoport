# PhotoPort Configuration

Rails.application.configure do
  # Enable Rack::Sendfile for efficient file serving
  config.public_file_server.enabled = true
  
  # Set up X-Sendfile headers for production (disabled for Docker/Puma direct serving)
  # if Rails.env.production?
  #   config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # For nginx
  #   config.action_dispatch.x_sendfile_header = 'X-Sendfile' # For Apache
  # end
  
  # Content serving configuration
  config.force_ssl = false # Set to true in production if using HTTPS
  
  # Cache configuration for images
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=31536000, immutable'
  }
end

# Load content modules on startup
require Rails.root.join('app', 'lib', 'content', 'site_config')
require Rails.root.join('app', 'lib', 'content', 'gallery')
require Rails.root.join('app', 'lib', 'content', 'menu')

# Initialize content singletons
Content::SiteConfig.instance
Content::Menu.instance