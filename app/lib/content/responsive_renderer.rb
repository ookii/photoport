module Content
  class ResponsiveRenderer < GalleryRenderer
    def partial_name
      'galleries/types/responsive'
    end

    def render_data(gallery, current_index = 0)
      # Get responsive configuration from gallery config
      gallery_config = find_gallery_config(gallery.slug)
      responsive_config = gallery_config[:responsive_config] || {}
      
      # Default configuration values
      spacing = responsive_config[:spacing] || '1rem'
      min_height = responsive_config[:min_height] || '500px'
      random = responsive_config[:random] || false
      
      # Get images and optionally randomize
      images = gallery.images
      images = images.shuffle if random
      
      {
        gallery: gallery,
        images: images,
        spacing: spacing,
        min_height: min_height,
        random: random,
        total_count: gallery.count
      }
    end

    def supports_navigation?
      false  # Responsive view shows all images at once
    end

    def supports_fullscreen?
      false  # Responsive galleries should not have click functionality
    end

    private

    def find_gallery_config(slug)
      site_config = Content::SiteConfig.instance
      site_config.galleries.find { |gallery| gallery[:slug] == slug } || {}
    end


  end
end 