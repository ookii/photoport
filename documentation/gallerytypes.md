# Gallery Types - High Level Specifications

## Overview

PhotoPort supports multiple gallery display types through a flexible renderer system. Each gallery can specify its `gallery_type` in the configuration.

## Available Gallery Types

### image-slider (Default)

**Description**: Single image slideshow with navigation controls, optimized for photography portfolios.

**Key Characteristics**:
- **Display**: One image at a time, full-width presentation
- **Navigation**: Circular arrow buttons with wraparound support  
- **Responsive**: Desktop arrows, mobile swipe gestures
- **Fullscreen**: Optional click-to-expand for larger viewing
- **Layout**: Minimal design focusing on image content

**Configuration**:
```yaml
gallery_type: "image-slider"
fullscreen_enabled: true  # Optional
```

**Best For**: Photography portfolios, art galleries, sequential storytelling

### grid

**Description**: Multi-column grid layout displaying all images simultaneously with configurable spacing and ordering.

**Key Characteristics**:
- **Display**: Multiple images in a responsive grid layout
- **Customizable**: Configurable columns and spacing
- **Automatic Sizing**: Images maintain aspect ratio and size automatically
- **Natural Display**: No rounded corners or visual effects - images display naturally
- **Random Ordering**: Optional random image shuffle on each page load
- **Responsive**: Automatically adapts column count for mobile devices
- **Non-Interactive**: No hover effects or click functionality for clean presentation

**Configuration**:
```yaml
gallery_type: "grid"
fullscreen_enabled: true  # Optional (ignored for grid galleries)
grid_config:
  columns: 3              # Number of columns (default: 3)
  spacing: "0.75rem"      # Gap between images (default: "1rem")
  random: false           # Randomize image order on each load (default: false)
```

**Responsive Behavior**:
- **Desktop (1200px+)**: Uses full configured column count
- **Tablet (768px-1200px)**: Maximum 3 columns regardless of configuration
- **Mobile (480px-768px)**: Maximum 2 columns with reduced spacing
- **Small Mobile (<480px)**: Single column layout

**Best For**: Portrait photography collections, portfolio overviews, photo collections, browsable image sets

### responsive

**Description**: Elegant layout that maximizes landscape images while ensuring all images have equal height, creating a balanced visual flow within the 1200px content width.

**Key Characteristics**:
- **Equal Heights**: All images have the same height regardless of aspect ratio
- **Optimized Landscape**: Landscape images are displayed as large as possible
- **Balanced Layout**: Images flow naturally to fill the available width
- **Content Width**: Respects the 1200px maximum content width
- **Responsive**: Automatically adapts to different screen sizes
- **Non-Interactive**: No hover effects or click functionality for clean presentation

**Configuration**:
```yaml
gallery_type: "responsive"
fullscreen_enabled: true  # Optional (ignored for responsive galleries)
responsive_config:
  spacing: "1rem"         # Gap between images (default: "1rem")
  random: false           # Randomize image order on each load (default: false)
```

**Layout Behavior**:
- **Landscape + Portrait**: Landscape image takes maximum available space, portrait image fills remaining space
- **Two Landscapes**: Both images share equal width
- **Two Portraits**: Both images share equal width
- **Single Image**: Takes full available width
- **Multiple Images**: Flow naturally to fill the 1200px container

**Best For**: Mixed photography collections, photo journals, galleries with varied image orientations

## System Architecture

- **Gallery Class**: Supports `gallery_type` attribute with `'image-slider'` default
- **Renderer System**: Plugin-style architecture for adding new gallery types
- **View System**: Template partials for each gallery type
- **Configuration**: YAML-based gallery type specification

## Future Gallery Types

The system is designed to support additional types such as:
- **Grid galleries**: Multiple images in responsive grids
- **Slideshow galleries**: Auto-advancing displays
- **Masonry galleries**: Pinterest-style layouts
- **Lightbox galleries**: Thumbnail grids with popup viewing