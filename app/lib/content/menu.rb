require 'yaml'

module Content
  class Menu
    attr_reader :items

    def initialize
      @items = load_menu_items
    end

    def self.instance
      # In development mode, always reload to pick up changes
      if Rails.env.development?
        new
      else
        @instance ||= new
      end
    end

    def render_menu(current_path = nil)
      items.map { |item| render_menu_item(item, current_path) }
    end

    def separator_character
      menu_config = load_menu_config
      menu_config['separator_character'] || '|'
    end

    private

    def load_menu_items
      site_config = Content::SiteConfig.instance
      menu_config = load_menu_config
      
      # Load main menu items from menu.yml
      main_menu_items = site_config.menu.map { |item| parse_menu_item(item) }
      
      # Load custom menu links from menu.yml
      custom_menu_links = menu_config['custom_menu_links'] || []
      custom_menu_items = parse_custom_menu_links(custom_menu_links)
      
      # Combine main menu and custom links
      main_menu_items + custom_menu_items
    end

    def parse_menu_item(item)
      # Handle separator items
      if item['separator']
        return {
          separator: true,
          separator_char: item['separator'] == true ? nil : item['separator'],
          label: nil,
          href: nil,
          children: nil,
          active: false
        }
      end
      
      {
        label: item['label'],
        href: item['href'],
        bold: item['bold'] == true,
        children: item['children'] ? item['children'].map { |child| parse_menu_item(child) } : nil,
        active: false
      }
    end

    def load_menu_config
      file_path = Rails.root.join('config', 'content', 'menu.yml')
      return {} unless File.exist?(file_path)
      
      YAML.load_file(file_path) || {}
    rescue Psych::SyntaxError => e
      Rails.logger.error "YAML syntax error in menu.yml: #{e.message}"
      {}
    end

    def parse_custom_menu_links(custom_menu_links_config)
      return [] unless custom_menu_links_config.is_a?(Array)
      
      custom_menu_links_config.map do |link|
        # Handle separator items
        if link['separator']
          {
            separator: true,
            separator_char: link['separator'] == true ? nil : link['separator'],
            label: nil,
            href: nil,
            external: false,
            children: nil,
            active: false
          }
        else
          {
            label: link['label']&.strip,
            href: link['href']&.strip,
            bold: link['bold'] == true,
            external: link['external'] == true,
            children: nil,
            active: false
          }
        end
      end.select { |link| link[:separator] || (link[:label].present? && link[:href].present?) }
    end

    def render_menu_item(item, current_path)
      item_copy = item.dup
      item_copy[:active] = item_active?(item, current_path)
      
      if item[:children]
        item_copy[:children] = item[:children].map { |child| render_menu_item(child, current_path) }
        item_copy[:has_active_child] = item_copy[:children].any? { |child| child[:active] || child[:has_active_child] }
      end
      
      item_copy
    end

    def item_active?(item, current_path)
      return false unless current_path && item[:href]
      
      if item[:href] == '/'
        current_path == '/'
      else
        current_path.start_with?(item[:href])
      end
    end
  end
end