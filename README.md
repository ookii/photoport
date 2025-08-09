# PhotoPort

A modern, fast, and customizable photo portfolio application built with Rails. Perfect for photographers who want a clean, professional portfolio with powerful customization options and no database complexity.

## ✨ Features

### 🖼️ Multiple Gallery Types
- **Image Slider**: Traditional one-image-at-a-time navigation with smooth transitions
- **Grid Gallery**: Multi-column grid layout with customizable spacing and columns  
- **Responsive Gallery**: Adaptive layout that automatically adjusts to any screen size

### 📱 Modern Interface
- **Touch & Swipe Support**: Mobile-friendly navigation with gesture controls
- **Keyboard Navigation**: Arrow keys (←/→) or vim-style (h/l) navigation
- **Fullscreen Mode**: Immersive viewing experience with escape key support
- **Responsive Menu**: Hierarchical navigation with mobile-friendly dropdowns

### 📄 Custom Pages
- **Markdown Support**: Create custom pages using GitHub Flavored Markdown
- **SEO Optimized**: Auto-generated meta descriptions from page content
- **Easy Management**: Simple file-based content management

### ⚡ Performance & Infrastructure  
- **CDN Ready**: Built-in CloudFront integration for global image delivery
- **Docker Support**: Complete containerization with persistent volumes
- **No Database**: File-based architecture for simple deployment
- **Image Optimization**: Smart caching and prefetching for fast loading

### 🎨 Customization
- **Custom CSS**: Add your own styles via `custom.css` file
- **Theme Control**: Comprehensive styling options via YAML configuration
- **Flexible Layout**: Configurable content width, spacing, and typography

## 🚀 Quick Start

### Option 1: Docker (Recommended)

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd photoport
   ```

2. **Start with Docker**:
   ```bash
   docker compose up -d
   ```

3. **Visit**: `http://localhost:3000`

That's it! PhotoPort comes with example galleries and an About page ready to customize.

### Option 2: Native Development

1. **Install Dependencies**:
   ```bash
   bundle install
   npm install
   ```

2. **Start Server**:
   ```bash
   rails server
   ```

3. **Visit**: `http://localhost:3000`

## 📁 Adding Content

### Adding Images
1. Create a directory in `galleries/`: `galleries/my-trip/`
2. Add images: `my-trip/photo1.jpg`, `my-trip/photo2.jpg`, etc.
3. Configure in `config/content/pages.yml`:
   ```yaml
   galleries:
     - slug: "my-trip"
       title: "My Amazing Trip"
       dir: "galleries/my-trip"
       gallery_type: "image-slider"
   ```
4. Add to menu in `config/content/menu.yml`

### Adding Custom Pages
1. Create markdown file: `pages/contact.md`
2. Add to `config/content/pages.yml`:
   ```yaml
   pages:
     - slug: "contact"
       title: "Contact Me"
       file: "pages/contact.md"
   ```
3. Add to menu: `{label: "Contact", href: "/contact"}`

## ⚙️ Configuration

PhotoPort is configured entirely through YAML files in `config/content/`:

- **`pages.yml`**: Galleries and custom pages
- **`menu.yml`**: Navigation structure  
- **`styling.yml`**: Colors, fonts, layout, branding
- **`site.yml`**: CDN settings, security options
- **`custom.css`**: Your custom styles

## 🏗️ Project Structure

```
PhotoPort/
├── galleries/                # Your image collections
│   ├── japan/               # Example galleries with images
│   ├── iceland/
│   └── belgium/
├── pages/                    # Custom markdown pages
│   └── about.md             # Example about page
├── config/content/           # All configuration files
│   ├── pages.yml            # Gallery & page definitions
│   ├── menu.yml             # Navigation structure
│   ├── styling.yml          # Colors, fonts, branding
│   ├── site.yml             # CDN & security settings
│   └── custom.css           # Your custom styles
└── docker-compose.yml       # Easy Docker setup
```

## 🎨 Customization Examples

### Styling Your Site
Edit `config/content/styling.yml`:
```yaml
site_name: "Your Name"
site_subheader: "Your Photography"
page_title: "Your Name - Photography Portfolio"

colors:
  background_color: "#ffffff"
  text_color: "#1a1a1a"
  link_color: "#2563eb"

layout:
  max_content_width: "1525px"  # Control image size
```

### Creating Navigation
Edit `config/content/menu.yml`:
```yaml
menu:
  - label: "Home"
    href: "/"
  - label: "Galleries"
    children:
      - label: "Travel"
        href: "/travel"
      - label: "Portraits"  
        href: "/portraits"

custom_menu_links:
  - separator: true
  - label: "About"
    href: "/about"
```

## 🛠️ Technology Stack

- **Backend**: Ruby 3.4.5 + Rails 7.1
- **Frontend**: Tailwind CSS + Stimulus JS
- **Markdown**: CommonMarker (GitHub Flavored)
- **Deployment**: Docker + Docker Compose
- **Architecture**: File-based (no database required)

## 📊 Features Deep Dive

### Gallery Types
- **Image Slider**: Perfect for storytelling, one image at a time
- **Grid Layout**: Great for showcasing multiple images at once
- **Responsive**: Adapts beautifully to any screen size

### SEO & Performance
- Auto-generated meta descriptions from markdown content
- Image prefetching for smooth navigation  
- CDN-ready for global distribution
- Mobile-optimized responsive design

### Developer Experience
- Hot reloading in development mode
- Comprehensive error handling
- Natural filename sorting (image-1, image-2, image-10)
- Docker containerization for easy deployment

## 🤝 Contributing

PhotoPort is designed to be easily customizable and extensible. The file-based architecture makes it simple to add new features or modify existing ones.

## 📄 License

MIT License - feel free to use PhotoPort for your photography portfolio!

---

**Ready to showcase your photography?** Get started with PhotoPort in under 5 minutes! 📸✨