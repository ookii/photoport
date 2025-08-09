#!/bin/bash
set -e

echo "Starting PhotoPort initialization..."


# Function to copy defaults if directory is empty
copy_defaults_if_empty() {
    local target_dir=$1
    local source_dir=$2
    local description=$3
    
    mkdir -p "$target_dir"
    
    # Count actual content files (excluding system files like lost+found)
    local content_count=$(find "$target_dir" -mindepth 1 -maxdepth 1 ! -name "lost+found" 2>/dev/null | wc -l)
    
    if [ "$content_count" -gt 0 ]; then
        echo "$description directory already has content, skipping initialization."
    else
        echo "Initializing $description with default content..."
        if [ -d "$source_dir" ] && [ "$(ls -A $source_dir 2>/dev/null)" ]; then
            cp -r "$source_dir"/* "$target_dir/"
            echo "$description initialized successfully."
        else
            echo "Warning: No default $description found to copy."
        fi
    fi
}

# Initialize galleries if empty
copy_defaults_if_empty "/app/galleries" "/app/defaults/galleries" "galleries"

# Initialize config if empty
copy_defaults_if_empty "/app/config/content" "/app/defaults/config" "configuration"

# Initialize pages if empty
copy_defaults_if_empty "/app/pages" "/app/defaults/pages" "pages"

# Create log directory if it doesn't exist
mkdir -p /app/log

# Generate SECRET_KEY_BASE if not provided
if [ -z "$SECRET_KEY_BASE" ]; then
    echo "Generating SECRET_KEY_BASE..."
    export SECRET_KEY_BASE=$(openssl rand -hex 64)
fi

# Set proper permissions (skip if running as non-root)
if [ "$(id -u)" = "0" ]; then
    chown -R nobody:nogroup /app/galleries /app/config/content /app/log 2>/dev/null || true
fi

echo "PhotoPort initialization complete!"


# Execute the main command
exec "$@"