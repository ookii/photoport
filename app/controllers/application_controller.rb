class ApplicationController < ActionController::Base
  before_action :load_site_config
  before_action :load_menu

  def favicon
    favicon_files = [
      { path: Rails.root.join('config', 'content', 'favicon.ico'), type: 'image/x-icon' },
      { path: Rails.root.join('config', 'content', 'favicon.png'), type: 'image/png' },
      { path: Rails.root.join('config', 'content', 'favicon.svg'), type: 'image/svg+xml' }
    ]
    
    favicon_files.each do |favicon|
      if File.exist?(favicon[:path])
        send_file favicon[:path], type: favicon[:type], disposition: 'inline'
        return
      end
    end
    
    head :not_found
  end

  protected

  def load_site_config
    @site_config = Content::SiteConfig.instance
  end

  def load_menu
    @menu = Content::Menu.instance
    @menu_items = @menu.render_menu(request.path)
  end
end