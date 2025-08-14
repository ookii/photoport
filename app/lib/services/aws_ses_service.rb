require 'aws-sdk-ses'

class AwsSesService
  def initialize
    @site_config = Content::SiteConfig.instance
    @ses_config = @site_config.contact[:aws_ses]
    
    validate_configuration
    
    @ses_client = Aws::SES::Client.new(
      region: @ses_config[:region],
      access_key_id: @ses_config[:access_key_id],
      secret_access_key: @ses_config[:secret_access_key]
    )
  end

  def send_email(to:, subject:, body:)
    raise AwsSesError, "AWS SES not configured properly" unless configured?
    
    begin
      response = @ses_client.send_email({
        source: format_sender_email,
        destination: {
          to_addresses: [to]
        },
        message: {
          subject: {
            data: subject,
            charset: 'UTF-8'
          },
          body: {
            text: {
              data: body,
              charset: 'UTF-8'
            }
          }
        }
      })
      
      log_email_delivery(response, to, subject)
      Rails.logger.info "Email sent successfully via AWS SES to #{to}"
      Rails.logger.info "SES Message ID: #{response.message_id}"
      
      true
      
    rescue Aws::SES::Errors::ServiceError => e
      Rails.logger.error "AWS SES API error: #{e.code} - #{e.message}"
      raise AwsSesError, "Failed to send email: #{e.message}"
    rescue => e
      Rails.logger.error "AWS SES service error: #{e.message}"
      raise AwsSesError, "Email delivery failed: #{e.message}"
    end
  end

  def configured?
    @ses_config[:access_key_id].present? &&
    @ses_config[:secret_access_key].present? &&
    @ses_config[:from_email].present? &&
    @ses_config[:to_email].present?
  end

  def configuration_status
    status = {}
    status[:region] = @ses_config[:region].present? ? 'configured' : 'missing'
    status[:access_key_id] = @ses_config[:access_key_id].present? ? 'configured' : 'missing'
    status[:secret_access_key] = @ses_config[:secret_access_key].present? ? 'configured' : 'missing'
    status[:from_email] = @ses_config[:from_email].present? ? 'configured' : 'missing'
    status[:from_name] = @ses_config[:from_name].present? ? 'configured' : 'missing'
    status[:to_email] = @ses_config[:to_email].present? ? 'configured' : 'missing'
    status
  end

  private

  def validate_configuration
    errors = []
    
    if @ses_config[:access_key_id].blank?
      errors << "AWS Access Key ID not configured (set AWS_ACCESS_KEY_ID environment variable)"
    end
    
    if @ses_config[:secret_access_key].blank?
      errors << "AWS Secret Access Key not configured (set AWS_SECRET_ACCESS_KEY environment variable)"
    end
    
    if @ses_config[:from_email].blank?
      errors << "AWS SES from_email not configured in contact.yml"
    end
    
    if @ses_config[:to_email].blank?
      errors << "AWS SES to_email not configured in contact.yml"
    end
    
    unless valid_email?(@ses_config[:from_email])
      errors << "AWS SES from_email is not a valid email address"
    end
    
    unless valid_email?(@ses_config[:to_email])
      errors << "AWS SES to_email is not a valid email address"
    end
    
    if errors.any?
      Rails.logger.error "AWS SES configuration errors: #{errors.join(', ')}"
      raise AwsSesConfigurationError, errors.join('; ')
    end
  end

  def valid_email?(email)
    return false if email.blank?
    email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    email.match?(email_regex)
  end

  def format_sender_email
    if @ses_config[:from_name].present?
      "#{@ses_config[:from_name]} <#{@ses_config[:from_email]}>"
    else
      @ses_config[:from_email]
    end
  end

  def log_email_delivery(response, to, subject)
    Rails.logger.info "AWS SES email delivery attempt:"
    Rails.logger.info "  To: #{to}"
    Rails.logger.info "  Subject: #{subject}"
    Rails.logger.info "  From: #{format_sender_email}"
    Rails.logger.info "  Region: #{@ses_config[:region]}"
    Rails.logger.info "  Message ID: #{response.message_id}"
  end
end

class AwsSesError < StandardError; end
class AwsSesConfigurationError < AwsSesError; end