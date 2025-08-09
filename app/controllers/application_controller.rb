class ApplicationController < ActionController::Base
  before_action :load_site_config
  before_action :load_menu

  protected

  def load_site_config
    @site_config = Content::SiteConfig.instance
  end

  def load_menu
    @menu = Content::Menu.instance
    @menu_items = @menu.render_menu(request.path)
  end
end