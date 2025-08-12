class ImagesController < ApplicationController
  ALLOWED_EXTENSIONS = %w[.jpg .jpeg .png .webp].freeze
  CONTENT_TYPES = {
    '.jpg' => 'image/jpeg',
    '.jpeg' => 'image/jpeg',
    '.png' => 'image/png',
    '.webp' => 'image/webp'
  }.freeze

  def show
    gallery_slug = params[:gallery_slug]
    filename = params[:filename]

    unless valid_slug?(gallery_slug)
      render_not_found and return
    end

    unless valid_filename?(filename)
      render_not_found and return
    end

    file_path = build_secure_file_path(gallery_slug, filename)
    
    unless File.exist?(file_path)
      render_not_found and return
    end

    send_image_file(file_path, filename)
  end

  def show_page_image
    page_slug = params[:page_slug]
    filename = params[:filename]

    unless valid_slug?(page_slug)
      render_not_found and return
    end

    unless valid_filename?(filename)
      render_not_found and return
    end

    file_path = build_secure_page_image_path(page_slug, filename)
    
    unless file_path && File.exist?(file_path)
      render_not_found and return
    end

    send_image_file(file_path, filename)
  end

  private

  def valid_slug?(slug)
    slug.present? && slug.match?(/\A[a-z0-9\-_]+\z/)
  end

  def valid_filename?(filename)
    return false unless filename.present?
    return false if filename.include?('..')
    return false if filename.start_with?('.')
    
    extension = File.extname(filename).downcase
    ALLOWED_EXTENSIONS.include?(extension)
  end

  def build_secure_file_path(gallery_slug, filename)
    galleries_root = Rails.root.join('galleries')
    gallery_path = galleries_root.join(gallery_slug)
    file_path = gallery_path.join(filename)
    
    resolved_path = file_path.realpath rescue nil
    return nil unless resolved_path
    
    unless resolved_path.to_s.start_with?(galleries_root.realpath.to_s)
      return nil
    end
    
    resolved_path
  end

  def build_secure_page_image_path(page_slug, filename)
    pages_root = Rails.root.join('pages')
    
    # Try direct image in page directory first: pages/about/image.jpg
    page_path = pages_root.join(page_slug)
    file_path = page_path.join(filename)
    
    if File.exist?(file_path)
      resolved_path = file_path.realpath rescue nil
      return nil unless resolved_path
      
      unless resolved_path.to_s.start_with?(pages_root.realpath.to_s)
        return nil
      end
      
      return resolved_path
    end
    
    # Try images subdirectory: pages/about/images/image.jpg
    images_path = page_path.join('images')
    file_path = images_path.join(filename)
    
    resolved_path = file_path.realpath rescue nil
    return nil unless resolved_path
    
    unless resolved_path.to_s.start_with?(pages_root.realpath.to_s)
      return nil
    end
    
    resolved_path
  end

  def send_image_file(file_path, filename)
    extension = File.extname(filename).downcase
    content_type = CONTENT_TYPES[extension] || 'image/jpeg'
    
    response.headers['Cache-Control'] = 'public, max-age=31536000, immutable'
    response.headers['Content-Type'] = content_type
    
    send_file file_path, 
              type: content_type, 
              disposition: 'inline',
              filename: filename
  end


  def render_not_found
    head :not_found
  end
end