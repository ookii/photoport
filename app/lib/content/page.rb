require 'commonmarker'
require_relative 'contact_form_parser'

module Content
  class Page
    attr_reader :slug, :title, :file_path, :content, :html_content, :meta_description, :contact_forms

    def initialize(slug)
      @slug = slug
      page_config = find_page_config(slug)
      
      raise "Page '#{slug}' not found" unless page_config
      
      @title = page_config[:title]
      @file_path = page_config[:file]
      load_content
    end

    def exists?
      File.exist?(full_file_path)
    end

    private

    def find_page_config(slug)
      site_config = Content::SiteConfig.instance
      site_config.pages&.find { |page| page[:slug] == slug }
    end

    def load_content
      return unless exists?
      
      @content = File.read(full_file_path)
      
      # Parse and process contact forms
      form_parser = ContactFormParser.parse(@content.dup)
      @contact_forms = form_parser
      processed_content = form_parser.processed_content
      
      @html_content = CommonMarker.render_html(processed_content, [:GITHUB_PRE_LANG, :UNSAFE], [:table, :strikethrough, :autolink, :tasklist])
      @meta_description = extract_meta_description
      
      # Log any form parsing errors
      if form_parser.errors.any?
        Rails.logger.warn "Contact form parsing errors for page #{slug}: #{form_parser.errors.join(', ')}"
      end
    rescue => e
      Rails.logger.error "Error loading page content for #{slug}: #{e.message}"
      @content = "Error loading page content."
      @html_content = "<p>Error loading page content.</p>"
      @meta_description = ""
      @contact_forms = nil
    end

    def full_file_path
      Rails.root.join(file_path)
    end

    def extract_meta_description
      return "" if content.blank?
      
      # Remove markdown headers and formatting
      plain_text = content.gsub(/^#+\s+/, '')  # Remove headers
                         .gsub(/\*\*(.*?)\*\*/, '\1')  # Remove bold
                         .gsub(/\*(.*?)\*/, '\1')      # Remove italic
                         .gsub(/\[(.*?)\]\(.*?\)/, '\1') # Remove links, keep text
                         .gsub(/`(.*?)`/, '\1')        # Remove code formatting
                         .gsub(/\n+/, ' ')             # Replace newlines with spaces
                         .strip
      
      # Get first paragraph or first ~155 characters for SEO
      first_paragraph = plain_text.split(/\n\s*\n/).first || plain_text
      
      if first_paragraph.length > 155
        # Find a good breaking point near 155 characters
        truncated = first_paragraph[0..152]
        last_space = truncated.rindex(' ')
        if last_space && last_space > 100  # Don't break too early
          truncated = truncated[0..last_space-1] + '...'
        else
          truncated += '...'
        end
        truncated
      else
        first_paragraph
      end
    end
  end
end