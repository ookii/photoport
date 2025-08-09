# Build stage - includes build tools
FROM ruby:3.4.5-slim AS builder

# Install build dependencies
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    npm \
    build-essential \
    libvips-dev \
    libyaml-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set bundle configuration consistently (include development gems for flexibility)
ENV BUNDLE_PATH="/usr/local/bundle"

WORKDIR /app

# Copy dependency files
COPY Gemfile Gemfile.lock ./
COPY package*.json ./

# Install Ruby gems (with native extensions compiled)
RUN bundle install --jobs 4

# Install Node dependencies
RUN npm ci --only=production

# Runtime stage - minimal runtime dependencies
FROM ruby:3.4.5-slim AS runtime

# Install only runtime dependencies (no build tools)
RUN apt-get update -qq && apt-get install -y \
    libvips42 \
    libyaml-0-2 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y \
    && apt-get clean

# Set bundle environment variables (allow RAILS_ENV to be overridden at runtime)
ENV BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_BIN="/usr/local/bundle/bin" \
    PATH="/usr/local/bundle/bin:$PATH" \
    SECRET_KEY_BASE="dummy_secret_key_for_docker_please_change_in_production"

WORKDIR /app

# Create non-root user first (before copying files)
RUN groupadd -r photoport && useradd -r -g photoport photoport

# Copy gems from builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy node_modules from builder stage  
COPY --from=builder /app/node_modules ./node_modules

# Copy application code and Gemfile.lock
COPY . .
COPY --from=builder /app/Gemfile.lock ./Gemfile.lock

# Create directories for persistent data
RUN mkdir -p /app/defaults/galleries \
    /app/defaults/config \
    /app/defaults/pages

# Copy current galleries, config, and pages as defaults
RUN cp -r galleries/* /app/defaults/galleries/ || true
RUN cp -r config/content/* /app/defaults/config/ || true
RUN cp -r pages/* /app/defaults/pages/ || true

# Create initialization script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create home directory for photoport user and set proper ownership
RUN mkdir -p /home/photoport && \
    chown -R photoport:photoport /app && \
    chown -R photoport:photoport /usr/local/bundle && \
    chown -R photoport:photoport /home/photoport

# Switch to non-root user
USER photoport

# Expose port
EXPOSE 3000

# Set entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]

# Default command - let Rails environment determine the mode
CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3000"]