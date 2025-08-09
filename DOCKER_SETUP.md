# PhotoPort Docker Setup

This Docker setup provides persistent storage for your galleries, configuration, and logs while providing sensible defaults for first-time users.

## Quick Start

1. **Generate a secret key (IMPORTANT for security):**
   ```bash
   # Generate a secure random secret key
   openssl rand -hex 64
   ```

2. **Create environment file:**
   Create `.env` file in your project directory:
   ```bash
   # .env
   SECRET_KEY_BASE=your_generated_secret_key_here
   ```

3. **Update docker-compose.yml to use the secret:**
   ```yaml
   services:
     photoport:
       # ... other settings ...
       env_file:
         - .env
   ```

4. **Build and run the container:**
   ```bash
   docker-compose up -d
   ```

5. **Access the application:**
   Open http://localhost:3000 in your browser

## What happens on first run

- **Galleries**: The existing sample galleries (grid, slider, responsive) are copied to persistent storage
- **Configuration**: The current config files (menu.yml, pages.yml, site.yml, styling.yml) are copied as defaults
- **Logs**: A persistent log directory is created

## Persistent Storage

The following directories are persistent across container restarts:

- `/app/galleries` - Your photo galleries
- `/app/config/content` - Configuration files (menu.yml, pages.yml, site.yml, styling.yml)  
- `/app/log` - Application logs

## Managing Your Content

### Adding New Galleries
The galleries are stored in a persistent Docker volume. You can add new galleries in two ways:

1. **Using bind mounts** (recommended - modify docker-compose.yml):
   ```yaml
   volumes:
     - ./my_galleries:/app/galleries
     - ./my_config:/app/config/content
     - ./my_logs:/app/log
   ```
   Then simply add gallery folders to `./my_galleries/` on your host machine.

2. **Copy to the Docker volume**:
   ```bash
   docker cp /path/to/your/gallery photoport_photoport_1:/app/galleries/
   ```

### Updating Configuration
The config files are stored in a persistent Docker volume and changes are immediately live:

1. **Using bind mounts** (recommended):
   Edit files directly in `./my_config/` on your host machine (site.yml, styling.yml, etc.)

2. **Edit files in the persistent volume**:
   ```bash
   # Find the volume location
   docker volume inspect photoport_config
   
   # Or copy from host to volume
   docker cp ./site.yml photoport_photoport_1:/app/config/content/
   ```

**Note:** Changes to config files are immediately active - no container restart needed.

## Docker Commands

- **Start**: `docker-compose up -d`
- **Stop**: `docker-compose down`
- **Rebuild**: `docker-compose up --build -d`
- **View logs**: `docker-compose logs -f`
- **Access container**: `docker exec -it photoport_photoport_1 /bin/bash`

## Data Management Best Practices

### Recommended Setup: Use Bind Mounts
For easy data management, modify your `docker-compose.yml` to use bind mounts instead of volumes:

```yaml
services:
  photoport:
    # ... other settings ...
    volumes:
      # Use local directories instead of Docker volumes
      - ./galleries:/app/galleries
      - ./config:/app/config/content  
      - ./logs:/app/log
```

With this setup:
- **Backup**: Just copy your local `./galleries`, `./config`, and `./logs` directories
- **Version Control**: Add your config files to git for change tracking
- **Easy Editing**: Edit files directly in your IDE/text editor
- **Portability**: Your data travels with your project directory

### If Using Docker Volumes (Not Recommended)
If you must use Docker volumes, here's how to access the data:

```bash
# View volume contents
docker run --rm -v photoport_galleries:/data alpine ls -la /data

# Copy data out of volume
docker run --rm -v photoport_galleries:/data -v $(pwd):/backup alpine \
  cp -r /data/* /backup/
```

**Recommendation**: Switch to bind mounts for simpler data management.