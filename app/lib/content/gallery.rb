require 'pathname'

module Content
  class Gallery
    attr_reader :slug, :title, :dir, :extensions, :images, :fullscreen_enabled, :gallery_type

    def initialize(slug)
      @slug = slug
      gallery_config = find_gallery_config(slug)
      
      raise "Gallery '#{slug}' not found" unless gallery_config
      
      @title = gallery_config[:title]
      @dir = gallery_config[:dir]
      @extensions = gallery_config[:extensions]
      @gallery_type = gallery_config[:gallery_type] || 'image-slider'
      @fullscreen_enabled = gallery_config[:fullscreen_enabled] || false
      @images = load_images
    end

    def image_at(index)
      return nil if images.empty?
      
      clamped_index = clamp_index(index)
      images[clamped_index]
    end

    def count
      images.count
    end

    def valid_index?(index)
      index >= 0 && index < count
    end

    def clamp_index(index)
      return 0 if images.empty?
      [[index, 0].max, images.count - 1].min
    end

    def prev_index(current_index)
      return nil if images.empty?
      current_index > 0 ? current_index - 1 : images.count - 1
    end

    def next_index(current_index)
      return nil if images.empty?
      current_index < (images.count - 1) ? current_index + 1 : 0
    end

    private

    def find_gallery_config(slug)
      site_config = Content::SiteConfig.instance
      site_config.galleries.find { |gallery| gallery[:slug] == slug }
    end

    def load_images
      gallery_path = Rails.root.join(dir)
      return [] unless Dir.exist?(gallery_path)

      Dir.entries(gallery_path)
         .select { |file| valid_image_file?(file) }
         .sort_by { |file| natural_sort_key(file) }
         .map.with_index { |filename, index| create_image_item(filename, index) }
    end

    def valid_image_file?(filename)
      return false if filename.start_with?('.')
      
      extension = File.extname(filename).downcase
      extensions.include?(extension)
    end

    def natural_sort_key(filename)
      # Split filename into parts, converting numeric parts to integers for natural sorting
      filename.scan(/\d+|\D+/).map { |part| part.match?(/\d+/) ? part.to_i : part }
    end

    def create_image_item(filename, index)
      {
        filename: filename,
        index: index,
        path: File.join(dir, filename),
        url_path: "/images/#{slug}/#{filename}"
      }
    end
  end
end