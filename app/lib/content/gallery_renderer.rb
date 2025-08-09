module Content
  class GalleryRenderer
    GALLERY_TYPES = {
      'image-slider' => 'Content::ImageSliderRenderer',
      'grid' => 'Content::GridRenderer',
      'responsive' => 'Content::ResponsiveRenderer'
    }.freeze

    def self.for(gallery_type)
      renderer_class = GALLERY_TYPES[gallery_type]
      raise "Unknown gallery type: #{gallery_type}" unless renderer_class
      
      renderer_class.constantize.new
    end

    def self.supported_types
      GALLERY_TYPES.keys
    end

    # Base interface that all gallery renderers must implement
    def partial_name
      raise NotImplementedError, "Gallery renderers must implement #partial_name"
    end

    def render_data(gallery, current_index = 0)
      raise NotImplementedError, "Gallery renderers must implement #render_data"
    end

    def supports_navigation?
      true
    end

    def supports_fullscreen?
      false
    end
  end
end