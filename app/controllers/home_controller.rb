class HomeController < ApplicationController
  before_action :setup_home_renderer
  
  def index
    @site_config = Content::SiteConfig.instance
    @galleries = load_galleries_with_preview
    @default_gallery_obj = load_default_gallery_object if @site_config.default_gallery
    @default_gallery = load_default_gallery if @site_config.default_gallery
    @current_image_index = (params[:index] || 0).to_i
    
    if @default_gallery_obj
      # Use renderer system for the default gallery display
      @render_data = @renderer&.render_data(@default_gallery_obj, @current_image_index)
    end
    
    # Legacy support for the existing home view data
    if @default_gallery
      @current_image = @default_gallery[:images][@current_image_index]
      @prev_index = @current_image_index > 0 ? @current_image_index - 1 : @default_gallery[:count] - 1
      @next_index = @current_image_index < (@default_gallery[:count] - 1) ? @current_image_index + 1 : 0
    end
    
    respond_to do |format|
      format.html
      format.json { render json: home_json }
    end
  end

  private

  def load_galleries_with_preview
    @site_config.galleries.map do |gallery_config|
      begin
        gallery = Content::Gallery.new(gallery_config[:slug])
        first_image = gallery.image_at(0)
        
        {
          slug: gallery_config[:slug],
          title: gallery_config[:title],
          image_count: gallery.count,
          preview_image_url: first_image ? first_image[:url_path] : nil,
          gallery_path: gallery.count > 0 ? gallery_path(gallery_config[:slug], 0) : nil
        }
      rescue => e
        Rails.logger.warn "Error loading gallery #{gallery_config[:slug]}: #{e.message}"
        {
          slug: gallery_config[:slug],
          title: gallery_config[:title],
          image_count: 0,
          preview_image_url: nil,
          gallery_path: nil,
          error: "Gallery not accessible"
        }
      end
    end
  end

  def load_default_gallery_object
    begin
      Content::Gallery.new(@site_config.default_gallery)
    rescue => e
      Rails.logger.warn "Error loading default gallery object #{@site_config.default_gallery}: #{e.message}"
      nil
    end
  end

  def load_default_gallery
    begin
      gallery = Content::Gallery.new(@site_config.default_gallery)
      {
        slug: @site_config.default_gallery,
        title: gallery.title,
        images: gallery.images,
        count: gallery.count
      }
    rescue => e
      Rails.logger.warn "Error loading default gallery #{@site_config.default_gallery}: #{e.message}"
      nil
    end
  end

  def setup_home_renderer
    return unless @site_config&.default_gallery
    
    begin
      default_gallery_obj = load_default_gallery_object
      return unless default_gallery_obj
      
      @renderer = Content::GalleryRenderer.for(default_gallery_obj.gallery_type)
    rescue => e
      Rails.logger.error "Failed to setup home renderer: #{e.message}"
      @renderer = Content::GalleryRenderer.for('image-slider') # fallback
    end
  end

  def home_json
    return {} unless @current_image
    
    {
      gallery_slug: @site_config.default_gallery,
      current_index: @current_image_index,
      total_count: @default_gallery[:count],
      image_url: @current_image[:url_path],
      prev_path: @prev_index ? home_with_index_path(@prev_index) : nil,
      next_path: @next_index ? home_with_index_path(@next_index) : nil
    }
  end
end