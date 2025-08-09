class GalleriesController < ApplicationController
  before_action :load_gallery
  before_action :validate_gallery_exists
  before_action :setup_renderer
  
  def show
    index = params[:index]&.to_i || 0
    
    @current_index = @gallery.clamp_index(index)
    @image = @gallery.image_at(@current_index)
    @total_count = @gallery.count
    @page_title = "#{@gallery.title} - #{@site_config.page_title}"
    
    if @image
      # Get render data from the gallery renderer
      @render_data = @renderer.render_data(@gallery, @current_index)
      @next_image_url = next_image_url_for_prefetch
      
      # Legacy data for JSON API compatibility
      @image_url = @image[:url_path]
      @prev_path = build_gallery_path(@gallery.prev_index(@current_index))
      @next_path = build_gallery_path(@gallery.next_index(@current_index))
    else
      @error_message = "No images found in this gallery"
    end
    
    respond_to do |format|
      format.html
      format.json { render json: gallery_json }
    end
  end

  private

  def load_gallery
    @gallery_slug = params[:gallery_slug]
    @gallery = Content::Gallery.new(@gallery_slug)
  rescue => e
    @gallery = nil
    @error_message = "Page not found"
  end

  def validate_gallery_exists
    if @gallery.nil? || @gallery.count == 0
      render 'galleries/not_found', status: :not_found
      return false
    end
  end

  def setup_renderer
    return unless @gallery
    
    @renderer = Content::GalleryRenderer.for(@gallery.gallery_type)
  rescue => e
    Rails.logger.error "Failed to load gallery renderer: #{e.message}"
    @renderer = Content::GalleryRenderer.for('image-slider') # fallback
  end

  def build_gallery_path(index)
    return nil unless index
    gallery_path(@gallery_slug, index)
  end

  def next_image_url_for_prefetch
    next_index = @gallery.next_index(@current_index)
    return nil unless next_index
    
    next_image = @gallery.image_at(next_index)
    next_image ? next_image[:url_path] : nil
  end

  def gallery_json
    {
      gallery_slug: @gallery_slug,
      current_index: @current_index,
      total_count: @total_count,
      image_url: @image_url,
      prev_path: @prev_path,
      next_path: @next_path,
      next_image_url: @next_image_url
    }
  end
end