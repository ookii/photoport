require_relative '../lib/services/aws_ses_service'
require 'net/http'
require 'uri'
require 'json'

class ContactController < ApplicationController
  protect_from_forgery with: :exception
  
  def submit
    begin
      # Validate form parameters
      validate_form_submission
      
      # Check honeypot for spam
      check_honeypot
      
      # Verify hCaptcha if enabled
      verify_hcaptcha if hcaptcha_enabled?
      
      # Extract form data
      form_data = extract_form_data
      
      # Send email via SendGrid
      send_contact_email(form_data)
      
      render json: { 
        success: true, 
        message: site_config.contact[:forms][:success_message] 
      }
      
    rescue ContactFormError => e
      Rails.logger.warn "Contact form validation error: #{e.message}"
      render json: { 
        success: false, 
        message: e.message 
      }, status: :unprocessable_entity
      
    rescue => e
      Rails.logger.error "Contact form submission error: #{e.message}"
      render json: { 
        success: false, 
        message: site_config.contact[:forms][:error_message] 
      }, status: :internal_server_error
    end
  end

  private

  def validate_form_submission
    raise ContactFormError, "Invalid request method" unless request.post?
    raise ContactFormError, "Missing form ID" unless params[:form_id].present?
    
    # Check for required contact fields
    contact_params = params.select { |key, _| key.to_s.start_with?('contact_') }
    raise ContactFormError, "No form data provided" if contact_params.empty?
  end

  def check_honeypot
    honeypot_field = site_config.contact[:forms][:honeypot_field]
    if params[honeypot_field].present?
      Rails.logger.warn "Honeypot triggered: #{honeypot_field} = #{params[honeypot_field]}"
      raise ContactFormError, "Spam detected"
    end
  end

  def extract_form_data
    form_data = {}
    
    params.each do |key, value|
      if key.to_s.start_with?('contact_')
        field_name = key.to_s.sub('contact_', '')
        form_data[field_name] = sanitize_input(value)
      end
    end
    
    # Validate required fields (basic check - field names ending with required fields)
    validate_required_fields(form_data)
    
    form_data
  end

  def sanitize_input(input)
    return '' unless input.present?
    
    # Basic XSS prevention
    input.to_s.strip
         .gsub(/<script[^>]*>.*?<\/script>/mi, '')
         .gsub(/<[^>]*>/, '')
         .truncate(1000) # Limit field length
  end

  def validate_required_fields(form_data)
    # Basic validation - ensure we have some content
    if form_data.values.all?(&:blank?)
      raise ContactFormError, "Please fill in at least one field"
    end
    
    # Email validation if email field is present
    email_field = form_data.find { |key, _| key.downcase.include?('email') }
    if email_field && email_field[1].present?
      unless valid_email?(email_field[1])
        raise ContactFormError, "Please enter a valid email address"
      end
    end
  end

  def valid_email?(email)
    email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    email.match?(email_regex)
  end

  def send_contact_email(form_data)
    email_service = AwsSesService.new
    
    subject = site_config.contact[:forms][:default_subject]
    email_body = format_email_body(form_data)
    
    email_service.send_email(
      to: site_config.contact[:aws_ses][:to_email],
      subject: subject,
      body: email_body
    )
  end

  def format_email_body(form_data)
    body = "New contact form submission:\n\n"
    
    form_data.each do |field_name, value|
      next if value.blank?
      
      formatted_field_name = field_name.humanize
      body += "#{formatted_field_name}: #{value}\n"
    end
    
    body += "\n"
    body += "Submitted at: #{Time.current.strftime('%Y-%m-%d %H:%M:%S %Z')}\n"
    body += "IP Address: #{request.remote_ip}\n"
    body += "User Agent: #{request.user_agent}\n"
    body += "Referrer: #{request.referer}\n" if request.referer
    
    body
  end

  def site_config
    @site_config ||= Content::SiteConfig.instance
  end

  def hcaptcha_enabled?
    site_config.contact[:hcaptcha][:enabled]
  end

  def verify_hcaptcha
    hcaptcha_response = params['h-captcha-response']
    
    if hcaptcha_response.blank?
      raise ContactFormError, "Please complete the captcha verification"
    end
    
    unless verify_hcaptcha_response(hcaptcha_response)
      raise ContactFormError, "Captcha verification failed. Please try again."
    end
  end

  def verify_hcaptcha_response(response_token)
    secret_key = site_config.contact[:hcaptcha][:secret_key]
    
    if secret_key.blank?
      Rails.logger.error "hCaptcha secret key not configured"
      return false
    end
    
    uri = URI('https://hcaptcha.com/siteverify')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 10
    
    http_request = Net::HTTP::Post.new(uri)
    http_request.set_form_data(
      'secret' => secret_key,
      'response' => response_token,
      'remoteip' => request.remote_ip
    )
    
    response = http.request(http_request)
    result = JSON.parse(response.body)
    
    result['success'] == true
    
  rescue => e
    Rails.logger.error "hCaptcha verification error: #{e.message}"
    false
  end
end

class ContactFormError < StandardError; end