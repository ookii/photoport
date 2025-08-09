# Ensure logger is properly initialized
Rails.application.configure do
  # Create log directory if it doesn't exist
  log_dir = Rails.root.join('log')
  Dir.mkdir(log_dir) unless Dir.exist?(log_dir)
  
  # Set up logger
  log_file = Rails.root.join('log', "#{Rails.env}.log")
  config.logger = ActiveSupport::Logger.new(log_file)
  config.logger.level = Rails.env.production? ? Logger::INFO : Logger::DEBUG
  
  # Ensure the logger is tagged properly
  config.logger = ActiveSupport::TaggedLogging.new(config.logger)
end