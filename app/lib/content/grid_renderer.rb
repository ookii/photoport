module Content
  class GridRenderer < GalleryRenderer
    def partial_name
      'galleries/types/grid'
    end

    def render_data(gallery, current_index = 0)
      # Get grid configuration from gallery config
      gallery_config = find_gallery_config(gallery.slug)
      grid_config = gallery_config[:grid_config] || {}
      
      # Default configuration values
      columns = grid_config[:columns] || 3
      spacing = grid_config[:spacing] || '1rem'
      random = grid_config[:random] || false
      
      # Get images and optionally randomize
      images = gallery.images
      images = images.shuffle if random
      
      {
        gallery: gallery,
        images: images,
        columns: columns,
        spacing: spacing,
        random: random,
        total_count: gallery.count
      }
    end

    def supports_navigation?
      false  # Grid view shows all images at once
    end

    def supports_fullscreen?
      false  # Grid galleries should not have click functionality
    end

    private

    def find_gallery_config(slug)
      site_config = Content::SiteConfig.instance
      site_config.galleries.find { |gallery| gallery[:slug] == slug } || {}
    end
  end
end