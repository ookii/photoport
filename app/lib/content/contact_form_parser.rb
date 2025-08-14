module Content
  class ContactFormParser
    FORM_START_PATTERN = /\{\{contact-form\}\}/
    FORM_END_PATTERN = /\{\{\/contact-form\}\}/
    FIELD_PATTERN = /^([^|]+)\|([^|]+)\|([^|]+)\|([^|]+)(?:\|(.+))?$/
    SUBMIT_PATTERN = /^submit_text\|(.+)$/

    attr_reader :fields, :submit_text, :form_id

    def initialize(content)
      @content = content
      @fields = []
      @submit_text = 'Submit'
      @form_id = SecureRandom.hex(8)
      @errors = []
    end

    def self.parse(content)
      parser = new(content)
      parser.extract_forms
      parser
    end

    def extract_forms
      # Find all form blocks first
      start_pos = @content.index(FORM_START_PATTERN)
      return unless start_pos
      
      # Find the end of the form block
      content_start = start_pos + "{{contact-form}}".length
      end_pos = @content.index(FORM_END_PATTERN, content_start)
      
      if end_pos
        # Extract the form content
        form_content = @content[content_start...end_pos].strip
        
        # Parse the form content
        parse_form_content(form_content)
        
        # Replace the form block with a placeholder that will be replaced with rendered HTML
        form_block_end = end_pos + "{{/contact-form}}".length
        form_placeholder = "<!-- CONTACT_FORM_PLACEHOLDER_#{@form_id} -->"
        @content = @content[0...start_pos] + form_placeholder + @content[form_block_end..-1]
      else
        @errors << "Malformed contact form: missing closing tag"
      end
    end

    def has_forms?
      @fields.any?
    end

    def valid?
      @errors.empty? && @fields.any?
    end

    def errors
      @errors
    end

    def processed_content
      @content
    end

    private


    def parse_form_content(form_content)
      form_content.each_line do |line|
        line = line.strip
        next if line.empty?

        if line.match(SUBMIT_PATTERN)
          @submit_text = $1.strip
        elsif line.match(FIELD_PATTERN)
          parse_field_line(line)
        else
          @errors << "Invalid form syntax: #{line}"
        end
      end
    end

    def parse_field_line(line)
      match = line.match(FIELD_PATTERN)
      return unless match

      name = sanitize_field_name(match[1].strip)
      type = match[2].strip
      required = match[3].strip
      label = match[4].strip
      options = match[5]&.strip

      # Validate field type
      unless %w[text email textarea].include?(type)
        @errors << "Invalid field type '#{type}' for field '#{name}'"
        return
      end

      # Validate required status
      unless %w[required optional].include?(required)
        @errors << "Invalid required status '#{required}' for field '#{name}'. Use 'required' or 'optional'"
        return
      end

      field = {
        name: name,
        type: type,
        required: required == 'required',
        label: label,
        options: parse_field_options(options)
      }

      @fields << field
    end

    def parse_field_options(options_string)
      options = {}
      return options unless options_string

      options_string.split(',').each do |option|
        if option.include?(':')
          key, value = option.split(':', 2)
          options[key.strip.to_sym] = value.strip
        end
      end

      options
    end

    def render_form_html
      # Form will be rendered by the view template
      ""
    end

    def sanitize_field_name(name)
      # Only allow alphanumeric characters, underscores, and hyphens
      sanitized = name.gsub(/[^a-zA-Z0-9_-]/, '_').downcase
      
      # Ensure it starts with a letter
      sanitized = "field_#{sanitized}" unless sanitized.match?(/^[a-z]/)
      
      # Limit length
      sanitized[0..50]
    end
  end
end