#!/bin/bash

# AWS S3 and CloudFront Deployment Script for PhotoPort Gallery
# This script syncs gallery images to S3 and invalidates CloudFront cache

set -e  # Exit on any error

# =============================================================================
# CONFIGURATION VARIABLES
# =============================================================================

# Function to extract values from site.yml
extract_from_site_yml() {
    local key_path="$1"
    if [ -f "config/content/site.yml" ]; then
        # Use ruby to parse YAML and extract the value
        ruby -ryaml -e "
            config = YAML.load_file('config/content/site.yml')
            keys = '$key_path'.split('.')
            value = config
            keys.each { |key| value = value[key] if value }
            puts value if value
        " 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# Configuration will be loaded after function definitions

# Other Configuration
AWS_PROFILE=""                  # Optional: AWS profile name (leave empty for default)

# Local Configuration
GALLERIES_DIR="galleries"       # Local galleries directory

# Sync Options
DELETE_REMOVED=true             # Delete files from S3 that don't exist locally
DRY_RUN=false                   # Set to true for testing without actual sync
VERBOSE=true                    # Show detailed output
PERM_CHECKS=false

# =============================================================================
# FUNCTIONS
# =============================================================================

# Print colored output
print_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

# Check if required variables are set
check_config() {
    print_info "Checking configuration..."
    
    if [[ -z "$S3_BUCKET" ]]; then
        print_error "S3_BUCKET is not set. Please edit this script and set your bucket name."
        exit 1
    fi
    
    if [[ -z "$CLOUDFRONT_DISTRIBUTION_ID" ]]; then
        print_warning "CLOUDFRONT_DISTRIBUTION_ID is not set. Skipping CloudFront invalidation."
    fi
    
    if [[ ! -d "$GALLERIES_DIR" ]]; then
        print_error "Galleries directory '$GALLERIES_DIR' not found."
        exit 1
    fi
    
    print_success "Configuration validated"
}

# Check AWS CLI and credentials
check_aws() {
    print_info "Checking AWS CLI and credentials..."
    
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Set AWS profile if specified
    if [[ -n "$AWS_PROFILE" ]]; then
        export AWS_PROFILE="$AWS_PROFILE"
        print_info "Using AWS profile: $AWS_PROFILE"
    fi
    
    # Test AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured or invalid."
        print_error "Run 'aws configure' or set AWS_PROFILE variable."
        exit 1
    fi
    
    local aws_account=$(aws sts get-caller-identity --query 'Account' --output text)
    print_success "AWS credentials validated (Account: $aws_account)"
}

# Check if S3 bucket exists and is accessible
check_s3_bucket() {
    print_info "Checking S3 bucket access..."
    
    if ! aws s3 ls "s3://$S3_BUCKET" &> /dev/null; then
        print_error "Cannot access S3 bucket 's3://$S3_BUCKET'"
        print_error "Make sure the bucket exists and you have proper permissions."
        exit 1
    fi
    
    print_success "S3 bucket access confirmed"
}

# Count local gallery files
count_local_files() {
    local count=$(find "$GALLERIES_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | wc -l)
    print_info "Found $count image files in local galleries"
    echo $count
}

# Sync galleries to S3
sync_to_s3() {
    print_info "Starting sync to S3..."
    
    local sync_options="--follow-symlinks --size-only"
    
    # Add verbose output if enabled
    if [[ "$VERBOSE" == false ]]; then
        sync_options="$sync_options --no-progress"
    fi
    
    # Add delete option if enabled
    if [[ "$DELETE_REMOVED" == true ]]; then
        sync_options="$sync_options --delete"
        print_warning "Delete mode enabled - files removed locally will be deleted from S3"
    fi
    
    # Add dry run option if enabled
    if [[ "$DRY_RUN" == true ]]; then
        sync_options="$sync_options --dryrun"
        print_warning "DRY RUN MODE - No actual changes will be made"
    fi
    
    # Build the full S3 destination path
    local s3_destination="s3://$S3_BUCKET/$S3_PREFIX/"
    
    print_info "Syncing from '$GALLERIES_DIR/' to '$s3_destination'"
    print_info "Sync options: $sync_options"
    
    # Perform the sync
    aws s3 sync "$GALLERIES_DIR/" "$s3_destination" \
        $sync_options \
        --cache-control "$CACHE_CONTROL" \
        --metadata-directive REPLACE \
        --exclude "*.DS_Store" \
        --exclude "*.gitignore" \
        --exclude "README*" \
        --include "*.jpg" \
        --include "*.jpeg" \
        --include "*.png" \
        --include "*.webp" \
        --include "*.JPG" \
        --include "*.JPEG" \
        --include "*.PNG" \
        --include "*.WEBP"
    
    if [[ $? -eq 0 ]]; then
        print_success "S3 sync completed successfully"
    else
        print_error "S3 sync failed"
        exit 1
    fi
}

# Invalidate CloudFront cache
invalidate_cloudfront() {
    if [[ -z "$CLOUDFRONT_DISTRIBUTION_ID" ]]; then
        print_warning "Skipping CloudFront invalidation (no distribution ID provided)"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "DRY RUN: Would invalidate CloudFront paths: /$S3_PREFIX/*"
        return 0
    fi
    
    print_info "Creating CloudFront invalidation..."
    
    local invalidation_paths="/$S3_PREFIX/*"
    local invalidation_id=$(aws cloudfront create-invalidation \
        --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" \
        --paths "$invalidation_paths" \
        --query 'Invalidation.Id' \
        --output text)
    
    if [[ $? -eq 0 ]]; then
        print_success "CloudFront invalidation created (ID: $invalidation_id)"
        print_info "Invalidation may take 10-15 minutes to complete"
        print_info "Check status: aws cloudfront get-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --id $invalidation_id"
    else
        print_error "CloudFront invalidation failed"
        exit 1
    fi
}

# Display summary
show_summary() {
    print_info "=== DEPLOYMENT SUMMARY ==="
    print_info "Local directory: $GALLERIES_DIR"
    print_info "S3 destination: s3://$S3_BUCKET/$S3_PREFIX/"
    print_info "Cache control: $CACHE_CONTROL"
    print_info "Delete removed files: $DELETE_REMOVED"
    
    if [[ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]]; then
        print_info "CloudFront distribution: $CLOUDFRONT_DISTRIBUTION_ID"
    else
        print_info "CloudFront: Not configured"
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        print_warning "DRY RUN MODE - No actual changes were made"
    else
        print_success "Deployment completed successfully!"
    fi
    
    print_info "=========================="
}

# =============================================================================
# CONFIGURATION LOADING
# =============================================================================

# Load configuration from site.yml
print_info "Loading configuration from site.yml..."
S3_BUCKET=$(extract_from_site_yml "cdn.s3.bucket")
CLOUDFRONT_DISTRIBUTION_ID=$(extract_from_site_yml "cdn.cloudfront.distribution_id")
S3_PREFIX=$(extract_from_site_yml "cdn.s3.prefix")
CACHE_CONTROL=$(extract_from_site_yml "cdn.cache_control")
CONTENT_TYPE=$(extract_from_site_yml "cdn.content_type")

# Fallback to hardcoded values if site.yml is missing or incomplete
if [ -z "$S3_BUCKET" ]; then
    print_warning "S3 bucket not found in site.yml, using fallback"
    S3_BUCKET="photoport-prj"
fi

if [ -z "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
    print_warning "CloudFront distribution ID not found in site.yml, using fallback"
    CLOUDFRONT_DISTRIBUTION_ID="E1LEMFW0S3OX35"
fi

if [ -z "$S3_PREFIX" ]; then
    print_warning "S3 prefix not found in site.yml, using fallback"
    S3_PREFIX="images"
fi

if [ -z "$CACHE_CONTROL" ]; then
    CACHE_CONTROL="max-age=31536000, public"
fi

if [ -z "$CONTENT_TYPE" ]; then
    CONTENT_TYPE="image/jpeg"
fi

print_success "Configuration loaded: Bucket=$S3_BUCKET, Distribution=$CLOUDFRONT_DISTRIBUTION_ID, Prefix=$S3_PREFIX"

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    echo "PhotoPort Gallery S3/CloudFront Deployment Script"
    echo "================================================"
    
    # Configuration validation
    if [[ "$PERM_CHECKS" == true ]]; then
        check_config
        check_aws
        check_s3_bucket
    fi
 
    
    # Count local files
    local file_count=$(count_local_files)
    
    # Confirm deployment (unless dry run)
    if [[ "$DRY_RUN" != true ]]; then
        echo
        read -p "Ready to sync $file_count files to s3://$S3_BUCKET/$S3_PREFIX/. Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Deployment cancelled"
            exit 0
        fi
    fi
    
    echo
    
    # Execute deployment
    sync_to_s3
    invalidate_cloudfront
    
    echo
    show_summary
}

# =============================================================================
# SCRIPT OPTIONS PARSING
# =============================================================================

# Parse command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --no-delete)
            DELETE_REMOVED=false
            shift
            ;;
        --quiet)
            VERBOSE=false
            shift
            ;;
        --bucket)
            S3_BUCKET="$2"
            shift 2
            ;;
        --distribution-id)
            CLOUDFRONT_DISTRIBUTION_ID="$2"
            shift 2
            ;;
        --profile)
            AWS_PROFILE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run              Show what would be done without making changes"
            echo "  --no-delete            Don't delete files from S3 that don't exist locally"
            echo "  --quiet                Reduce output verbosity"
            echo "  --bucket BUCKET        Override S3 bucket name"
            echo "  --distribution-id ID   Override CloudFront distribution ID"
            echo "  --profile PROFILE      Use specific AWS profile"
            echo "  -h, --help             Show this help message"
            echo ""
            echo "Configuration:"
            echo "  Edit the script to set S3_BUCKET and CLOUDFRONT_DISTRIBUTION_ID variables"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            print_info "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Run main function
main "$@"
