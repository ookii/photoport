module Content
  class ImageSliderRenderer < GalleryRenderer
    def partial_name
      'galleries/types/image_slider'
    end

    def render_data(gallery, current_index = 0)
      current_index = gallery.clamp_index(current_index)
      current_image = gallery.image_at(current_index)

      {
        gallery: gallery,
        current_index: current_index,
        current_image: current_image,
        total_count: gallery.count,
        image_url: current_image&.dig(:url_path),
        prev_index: gallery.prev_index(current_index),
        next_index: gallery.next_index(current_index),
        has_navigation: gallery.count > 1
      }
    end

    def supports_navigation?
      true
    end

    def supports_fullscreen?
      true
    end
  end
end