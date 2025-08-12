Rails.application.routes.draw do
  root "home#index"
  get "home(/:index)", to: "home#index", as: :home_with_index,
      constraints: { index: /\d+/ }

  # Page routes - check for pages first
  get ":slug", to: "pages#show", as: :page,
      constraints: lambda { |request|
        slug = request.params[:slug]
        site_config = Content::SiteConfig.instance
        site_config.pages&.any? { |page| page[:slug] == slug }
      }

  # Clean gallery URLs: /japan, /iceland, etc.
  get ":gallery_slug(/:index)", to: "galleries#show", as: :gallery,
      constraints: { gallery_slug: /[a-z0-9\-_]+/, index: /\d+/ }

  get "images/:gallery_slug/:filename",
      to: "images#show",
      as: :image,
      constraints: { 
        gallery_slug: /[a-z0-9\-_]+/,
        filename: /[^\/]+/
      }

  get "pages/:page_slug/images/:filename",
      to: "images#show_page_image",
      as: :page_image,
      constraints: { 
        page_slug: /[a-z0-9\-_]+/,
        filename: /[^\/]+/
      }

  # Error pages
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  match "/422", to: "errors#unprocessable_entity", via: :all
end