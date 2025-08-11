require 'yaml'

module Content
  class SiteConfig
    attr_reader :site_name, :subheader, :page_title, :logo_path, :galleries, :pages, :menu, :styling, :default_gallery, :cdn, :security, :analytics, :custom_css, :footer

    def initialize
      load_config
    end

    def self.instance
      # In development mode, always reload to pick up changes
      if Rails.env.development?
        new
      else
        @instance ||= new
      end
    end

    def self.reload!
      @instance = nil
      instance
    end

    private

    def load_config
      pages_config = load_yaml_file('pages.yml')
      menu_config = load_yaml_file('menu.yml')
      styling_config = load_yaml_file('styling.yml')
      site_config = load_yaml_file('site.yml')
      # Fallback to cdn.yml for backward compatibility during migration
      cdn_config = site_config['cdn'] || load_yaml_file('cdn.yml')

      @site_name = styling_config['site_name'] || 'PhotoPort'
      @subheader = styling_config['site_subheader'] || ''
      @page_title = styling_config['page_title'] || @site_name
      @logo_path = styling_config['site_logo_path']
      @default_gallery = styling_config['site_default_gallery']
      @galleries = parse_galleries(pages_config['galleries'] || [])
      @pages = parse_pages(pages_config['pages'] || [])
      @menu = menu_config['menu'] || []
      @styling = parse_styling(styling_config)
      @cdn = parse_cdn(cdn_config)
      @security = parse_security(site_config['security'] || {})
      @analytics = parse_analytics(site_config['analytics'] || {})
      @custom_css = load_custom_css
      @footer = parse_footer(styling_config['footer'] || {})
    end

    def load_yaml_file(filename)
      file_path = Rails.root.join('config', 'content', filename)
      return {} unless File.exist?(file_path)
      
      YAML.load_file(file_path) || {}
    rescue Psych::SyntaxError => e
      Rails.logger.error "YAML syntax error in #{filename}: #{e.message}"
      {}
    end

    def parse_galleries(galleries_config)
      galleries_config.map do |gallery|
        {
          slug: gallery['slug'],
          title: gallery['title'],
          dir: gallery['dir'] || "galleries/#{gallery['slug']}",
          extensions: gallery['extensions'] || ['.jpg', '.jpeg', '.png', '.webp'],
          gallery_type: gallery['gallery_type'] || 'image-slider',
          fullscreen_enabled: gallery['fullscreen_enabled'] == true,
          grid_config: symbolize_keys(gallery['grid_config'] || {}),
          responsive_config: symbolize_keys(gallery['responsive_config'] || {})
        }
      end
    end

    def parse_pages(pages_config)
      pages_config.map do |page|
        {
          slug: page['slug'],
          title: page['title'],
          file: page['file'] || "pages/#{page['slug']}.md"
        }
      end
    end

    def symbolize_keys(hash)
      hash.transform_keys(&:to_sym)
    end

    def parse_styling(styling_config)
      colors = styling_config['colors'] || {}
      typography = styling_config['typography'] || {}
      layout = styling_config['layout'] || {}
      
      {
        # Colors
        background_color: colors['background_color'] || '#ffffff',
        text_color: colors['text_color'] || '#1a1a1a',
        link_color: colors['link_color'] || '#404040',
        hover_link_color: colors['hover_link_color'] || '#000000',
        accent_color: colors['accent_color'] || '#f5f5f5',
        header_background_color: colors['header_background_color'] || '#ffffff',
        secondary_text_color: colors['secondary_text_color'] || '#666666',
        border_color: colors['border_color'] || '#e5e5e5',
        
        # Typography
        primary_font: typography['primary_font'] || "'Lato', sans-serif",
        heading_font: typography['heading_font'] || "'Lato', sans-serif",
        font_weight_normal: typography['font_weight_normal'] || '400',
        font_weight_medium: typography['font_weight_medium'] || '500',
        font_weight_bold: typography['font_weight_bold'] || '700',
        
        # Header typography
        site_name_font_size: typography['site_name_font_size'] || '1.25rem',
        site_name_font_weight: typography['site_name_font_weight'] || '700',
        site_name_letter_spacing: typography['site_name_letter_spacing'] || 'normal',
        site_subheader_font_size: typography['site_subheader_font_size'] || '0.875rem',
        site_subheader_font_weight: typography['site_subheader_font_weight'] || '400',
        site_subheader_letter_spacing: typography['site_subheader_letter_spacing'] || 'normal',
        
        # Layout
        max_content_width: layout['max_content_width'] || '1200px',
        gallery_columns: layout['gallery_columns'] || '3',
        image_aspect_ratio: layout['image_aspect_ratio'] || '4:3',
        header_top_padding: layout['header_top_padding'] || '0.5rem'
      }
    end

    def parse_cdn(cdn_config)
      return default_cdn_config if cdn_config.nil? || cdn_config.empty?
      
      # Get environment-specific config if available
      env_config = cdn_config[Rails.env.to_s] || {}
      
      # Merge base config with environment-specific overrides
      {
        enabled: env_config['enabled'] || cdn_config['enabled'] || false,
        base_url: cdn_config['base_url'] || '',
        fallback_local: env_config['fallback_local'] || cdn_config['fallback_local'] || false,
        cache_busting: cdn_config['cache_busting'] || false,
        cache_control: cdn_config['cache_control'] || 'max-age=31536000, public',
        s3: parse_s3_config(cdn_config['s3'] || {}),
        cloudfront: parse_cloudfront_config(cdn_config['cloudfront'] || {})
      }
    end

    def default_cdn_config
      {
        enabled: false,
        base_url: '',
        fallback_local: true,
        cache_busting: false,
        cache_control: 'max-age=31536000, public',
        s3: { bucket: '', prefix: 'images' },
        cloudfront: { distribution_id: '' }
      }
    end

    def parse_s3_config(s3_config)
      {
        bucket: s3_config['bucket'] || '',
        prefix: s3_config['prefix'] || 'images'
      }
    end

    def parse_cloudfront_config(cloudfront_config)
      {
        distribution_id: cloudfront_config['distribution_id'] || ''
      }
    end

    def parse_security(security_config)
      {
        disable_right_click: security_config['disable_right_click'] == true
      }
    end

    def parse_analytics(analytics_config)
      {
        google_analytics_id: analytics_config['google_analytics_id']&.strip&.presence
      }
    end

    def load_custom_css
      file_path = Rails.root.join('config', 'content', 'custom.css')
      return '' unless File.exist?(file_path)
      
      File.read(file_path)
    rescue => e
      Rails.logger.error "Error loading custom CSS: #{e.message}"
      ''
    end

    def parse_footer(footer_config)
      {
        show_photoport_credit: footer_config['show_photoport_credit'] != false
      }
    end
  end
end