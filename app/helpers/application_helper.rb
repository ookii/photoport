module ApplicationHelper
  # Generate CDN-aware image URLs based on site configuration
  def cdn_image_url(path)
    # Get site configuration
    site_config = Content::SiteConfig.instance
    
    # Check if CDN is enabled and we're not in development with fallback
    if cdn_enabled? && should_use_cdn?
      "#{site_config.cdn[:base_url]}#{path}"
    else
      path  # local fallback
    end
  end

  private

  # Check if CDN is enabled in configuration
  def cdn_enabled?
    site_config = Content::SiteConfig.instance
    site_config.cdn && site_config.cdn[:enabled] == true
  end

  # Determine if we should use CDN based on environment and configuration
  def should_use_cdn?
    site_config = Content::SiteConfig.instance
    
    # Always use CDN in production unless explicitly disabled
    return true if Rails.env.production?
    
    # In development, only use CDN if fallback_local is false
    return !site_config.cdn[:fallback_local] if Rails.env.development?
    
    # Default to using CDN for other environments
    true
  end
end