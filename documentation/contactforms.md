# Contact Forms

PhotoPort supports adding contact forms to any custom page using a simple markup syntax. Forms are processed server-side and delivered via email using Amazon SES.

## Quick Start

1. **Configure AWS SES** (see Configuration section below)
2. **Add form markup** to any custom page
3. **Test the form** to ensure emails are delivered

## Form Syntax

Contact forms use a simple pipe-delimited syntax within special markers:

```markdown
{{contact-form}}
field_name|field_type|required_status|label|options
submit_text|Button Text
{{/contact-form}}
```

### Example

```markdown
# Contact Us

Get in touch with us using the form below.

{{contact-form}}
name|text|required|Full Name
email|email|required|Email Address
company|text|optional|Company Name
subject|text|required|Subject
message|textarea|required|Your Message|rows:6
submit_text|Send Message
{{/contact-form}}

We'll respond within 24 hours!
```

## Field Types

### Text Field
Single-line text input for names, subjects, etc.
```
name|text|required|Full Name
```

### Email Field
Email input with built-in validation.
```
email|email|required|Email Address
```

### Textarea Field
Multi-line text input for messages and longer content.
```
message|textarea|required|Your Message|rows:5
```

## Field Configuration

Each field line follows this format:
```
field_name|field_type|required_status|label|options
```

- **field_name**: Internal name (letters, numbers, underscore, hyphen only)
- **field_type**: `text`, `email`, or `textarea`
- **required_status**: `required` or `optional`
- **label**: Display text shown to users
- **options**: Additional settings (currently only `rows:N` for textarea)

### Required vs Optional Fields

- **required**: Field must be filled out before form submission
- **optional**: Field can be left blank

### Textarea Options

For textarea fields, you can specify the number of rows:
```
message|textarea|required|Your Message|rows:8
```

## Submit Button

The submit button text is defined using:
```
submit_text|Button Text
```

## Configuration

### AWS SES Setup

PhotoPort uses Amazon SES for email delivery. To configure:

1. **Sign up** for an [AWS account](https://aws.amazon.com/)
2. **Enable Amazon SES** in your chosen AWS region
3. **Create IAM credentials** with SES sending permissions
4. **Set environment variables**:
   ```bash
   export AWS_ACCESS_KEY_ID=your_access_key_here
   export AWS_SECRET_ACCESS_KEY=your_secret_key_here
   ```
5. **Update contact configuration** in `config/content/contact.yml`

### Contact Configuration File

Edit `config/content/contact.yml`:

```yaml
aws_ses:
  region: "us-east-1"  # AWS region for SES
  access_key_id: ""  # Uses AWS_ACCESS_KEY_ID environment variable
  secret_access_key: ""  # Uses AWS_SECRET_ACCESS_KEY environment variable
  from_email: "noreply@yoursite.com"
  from_name: "Your Website"
  to_email: "contact@yoursite.com"

forms:
  default_subject: "Website Contact Form Submission"
  success_message: "Thank you for your message! We'll get back to you soon."
  error_message: "There was an error sending your message. Please try again."
  honeypot_field: "website"  # Hidden field for spam protection
```

**Important**: Replace the email addresses with your actual domain and choose the appropriate AWS region.

### Email Verification

Amazon SES requires sender email verification:
1. Log into your AWS Console
2. Go to Simple Email Service (SES)
3. Navigate to Verified Identities
4. Verify your from_email address or entire domain
5. If using SES sandbox, also verify recipient email addresses

### hCaptcha Setup (Optional)

For additional spam protection, you can enable hCaptcha:

1. **Sign up** for an [hCaptcha account](https://www.hcaptcha.com/)
2. **Create a new site** and get your site key and secret key
3. **Set environment variables**:
   ```bash
   export HCAPTCHA_SITE_KEY=your_site_key_here
   export HCAPTCHA_SECRET_KEY=your_secret_key_here
   ```
4. **Enable hCaptcha** in `config/content/contact.yml`:
   ```yaml
   hcaptcha:
     enabled: true
     site_key: ""    # Uses HCAPTCHA_SITE_KEY environment variable
     secret_key: ""  # Uses HCAPTCHA_SECRET_KEY environment variable
   ```

When enabled, users must complete a captcha challenge before submitting the form.

## Form Behavior

### User Experience
- **AJAX Submission**: Forms submit without page reload
- **Loading States**: Submit button shows "Sending..." during submission
- **Success/Error Messages**: Clear feedback displayed to users
- **Form Reset**: Form clears automatically on successful submission
- **Responsive Design**: Forms work on all device sizes

### Email Format
Submitted forms generate structured emails containing:
- All form field values
- Submission timestamp
- User's IP address
- Browser information
- Referring page URL

### Security Features
- **CSRF Protection**: All forms include security tokens
- **Honeypot Spam Protection**: Hidden fields catch automated spam
- **hCaptcha Integration**: Optional captcha challenge for additional spam prevention
- **Input Sanitization**: All inputs are cleaned to prevent XSS attacks
- **Email Validation**: Email fields are validated for proper format
- **Field Length Limits**: Inputs are limited to prevent abuse

## Advanced Usage

### Multiple Contact Pages

You can create different contact forms for different purposes:

```yaml
# In config/content/pages.yml
pages:
  - slug: "contact"
    title: "General Contact"
    file: "pages/contact.md"
  - slug: "support"
    title: "Technical Support"
    file: "pages/support.md"
  - slug: "sales"
    title: "Sales Inquiry"
    file: "pages/sales.md"
```

Each page can have its own unique form with different fields.

### Custom Styling

Contact forms inherit your site's styling automatically. For custom styling, target these CSS classes:

- `.contact-form-container` - Main form wrapper
- `.form-field` - Individual field containers
- `.form-label` - Field labels
- `.form-input` - Text and email inputs
- `.form-textarea` - Textarea inputs
- `.contact-submit-btn` - Submit button
- `.success-message` - Success message display
- `.error-message` - Error message display

## Limitations

- **One form per page**: Only one contact form is supported per page
- **No file uploads**: File attachment support is not included
- **No database storage**: Form submissions are only sent via email
- **No custom validation**: Only basic validation (required fields, email format)

## Troubleshooting

### Form Not Appearing
1. Check form syntax - ensure proper pipe-delimited format
2. Verify opening and closing tags are present
3. Check Rails logs for parsing errors
4. Ensure page is properly configured in `pages.yml`

### Form Submission Errors
1. Verify all required fields are filled
2. Check browser console for JavaScript errors
3. Ensure CSRF protection is working
4. Check Rails logs for server-side errors

### Email Not Sending
1. Verify `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables are set
2. Check AWS IAM permissions for SES
3. Ensure sender email is verified in AWS SES console
4. Verify email addresses and region in `contact.yml` are correct
5. Check Rails logs for AWS SES API errors
6. If using SES sandbox, ensure recipient email is also verified

### Common Error Messages

- **"Error loading page content"**: Contact form parsing failed - check syntax
- **"Spam detected"**: Honeypot field was filled (usually by bots)
- **"Please complete the captcha verification"**: hCaptcha not completed
- **"Captcha verification failed"**: hCaptcha validation failed on server
- **"Please enter a valid email address"**: Email format validation failed
- **"There was an error sending your message"**: AWS SES delivery failed

## Testing

### Local Testing
1. Set up AWS SES credentials and verify email addresses
2. Configure test email addresses in contact.yml
3. Submit test form
4. Check email delivery
5. Verify form behavior (success message, form reset)

### Production Testing
1. Test from different devices
2. Verify email delivery to production address
3. Test required field validation
4. Test with invalid email addresses
5. Verify spam protection works

## Best Practices

### Form Design
- Keep forms short and focused
- Use clear, descriptive labels
- Mark required fields clearly
- Provide helpful error messages

### Email Configuration
- Use a dedicated "noreply" sending address
- Set up email forwarding to your main inbox
- Include auto-responder for better user experience
- Monitor AWS SES delivery statistics and bounce/complaint rates

### Security
- Regularly rotate AWS access keys
- Monitor form submissions for abuse
- Keep email addresses private
- Use strong CSRF protection