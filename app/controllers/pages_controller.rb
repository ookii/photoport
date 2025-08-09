class PagesController < ApplicationController
  before_action :load_page
  before_action :validate_page_exists
  
  def show
    @page_title = "#{@page.title} - #{@site_config.page_title}"
    @page_description = @page.meta_description
    
    respond_to do |format|
      format.html
    end
  end

  private

  def load_page
    @page_slug = params[:slug]
    @page = Content::Page.new(@page_slug)
  rescue => e
    @page = nil
    @error_message = "Page not found"
  end

  def validate_page_exists
    if @page.nil? || !@page.exists?
      render 'pages/not_found', status: :not_found
      return false
    end
  end
end