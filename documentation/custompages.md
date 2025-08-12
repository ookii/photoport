# Custom Pages

PhotoPort supports creating custom pages with Markdown content and HTML support, including the ability to embed images directly within your pages.

## Overview

Custom pages allow you to add static content pages to your PhotoPort site beyond the photo galleries. These pages support:

- **Markdown formatting** with GitHub Flavored Markdown features
- **Raw HTML** for advanced layouts and styling
- **Images** served directly from the pages directory
- **Responsive styling** that matches your site theme
- **SEO optimization** with automatic meta descriptions

## Creating Custom Pages

### 1. Create the Markdown File

Create a `.md` file in the `pages/` directory:

```
pages/
├── about.md
├── contact.md
└── services.md
```

### 2. Configure the Page

Add your page configuration to `config/content/pages.yml`:

```yaml
pages:
  - slug: "about"
    title: "About Me"
    file: "pages/about.md"
  
  - slug: "contact"
    title: "Contact"
    file: "pages/contact.md"
    
  - slug: "services"
    title: "Services"
    file: "pages/services.md"
```

**Configuration Fields:**
- `slug`: URL-friendly identifier (letters, numbers, hyphens only)
- `title`: Page title shown in browser and navigation
- `file`: Path to the markdown file relative to project root

### 3. Access Your Page

Your page will be accessible at: `https://yoursite.com/{slug}`

For example:
- `about.md` with slug `about` → `https://yoursite.com/about`
- `contact.md` with slug `contact` → `https://yoursite.com/contact`

## Markdown Content

### Basic Markdown

Your `.md` files support all standard Markdown features:

```markdown
# Main Heading

## Section Heading

This is a paragraph with **bold text** and *italic text*.

### Lists

- Item 1
- Item 2
- Item 3

### Links

[Visit my gallery](/galleries/japan)
[External link](https://example.com)

### Code

Inline `code` or code blocks:

```\`\`\`javascript
function hello() {
  console.log("Hello world!");
}
```\`\`\`
```

### GitHub Flavored Markdown

PhotoPort supports GitHub Flavored Markdown extensions:

**Tables:**
```markdown
| Feature | Supported |
|---------|-----------|
| Images  | ✓         |
| Tables  | ✓         |
| Tasks   | ✓         |
```

**Task Lists:**
```markdown
- [x] Completed task
- [ ] Pending task
- [ ] Another task
```

**Strikethrough:**
```markdown
~~This text is crossed out~~
```

### Raw HTML Support

You can embed raw HTML for advanced layouts:

```html
<div style="display: flex; gap: 20px;">
  <div style="flex: 1;">
    <h3>Column 1</h3>
    <p>Content here</p>
  </div>
  <div style="flex: 1;">
    <h3>Column 2</h3>
    <p>More content</p>
  </div>
</div>
```

## Adding Images to Custom Pages

PhotoPort supports serving images directly from the pages directory structure.

### Image Directory Structure

You have two options for organizing images:

**Option 1: Images subdirectory (Recommended)**
```
pages/
├── about.md
├── about/
│   └── images/
│       ├── portrait.jpg
│       ├── workspace.png
│       └── logo.webp
├── contact.md
└── contact/
    └── images/
        └── map.png
```

**Option 2: Direct in page directory**
```
pages/
├── about.md
├── about/
│   ├── portrait.jpg
│   ├── workspace.png
│   └── logo.webp
├── contact.md
└── contact/
    └── map.png
```

### Supported Image Formats

- `.jpg` / `.jpeg`
- `.png`
- `.webp`

### Referencing Images in Markdown/HTML

Use absolute paths that match your page slug:

**For images in subdirectory:**
```html
<img src="/pages/about/images/portrait.jpg" alt="My portrait">
<img src="/pages/contact/images/map.png" alt="Office location">
```

**For images in page directory:**
```html
<img src="/pages/about/portrait.jpg" alt="My portrait">
<img src="/pages/contact/map.png" alt="Office location">
```

### Image Path Resolution

The system automatically tries both locations when serving images:

1. **First**: `pages/{slug}/{filename}` (direct)
2. **Then**: `pages/{slug}/images/{filename}` (subdirectory)

This means you can mix both approaches or migrate between them without breaking links.

## Complete Example

### File Structure
```
pages/
├── about.md
└── about/
    └── images/
        ├── portrait.jpg
        └── workspace.jpg
```

### Configuration (`config/content/pages.yml`)
```yaml
pages:
  - slug: "about"
    title: "About Me"
    file: "pages/about.md"
```

### Page Content (`pages/about.md`)
```markdown
# About Me

Welcome to my photography portfolio.

<img src="/pages/about/images/portrait.jpg" alt="Portrait" style="width: 300px; border-radius: 8px;">

## My Studio

Here's my workspace where the magic happens:

<div style="text-align: center;">
  <img src="/pages/about/images/workspace.jpg" alt="My workspace" style="max-width: 100%; border-radius: 8px;">
</div>

## Photography Style

My work focuses on:

- **Authentic moments** and genuine emotions
- **Cultural diversity** and human connection  
- **Natural landscapes** and urban environments

[View my galleries](/galleries)
```

### Result
- Page accessible at: `https://yoursite.com/about`
- Images served at: 
  - `https://yoursite.com/pages/about/images/portrait.jpg`
  - `https://yoursite.com/pages/about/images/workspace.jpg`

## Advanced Usage

### Responsive Image Layouts

Create responsive image grids using HTML and CSS:

```html
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px;">
  <div>
    <img src="/pages/services/images/wedding.jpg" alt="Wedding Photography" style="width: 100%; border-radius: 8px;">
    <h3>Wedding Photography</h3>
    <p>Capture your special day...</p>
  </div>
  <div>
    <img src="/pages/services/images/portrait.jpg" alt="Portrait Sessions" style="width: 100%; border-radius: 8px;">
    <h3>Portrait Sessions</h3>
    <p>Professional portraits...</p>
  </div>
</div>
```

### Image Optimization Tips

1. **Optimize file sizes**: Compress images before uploading
2. **Use appropriate formats**: 
   - `.webp` for modern browsers (best compression)
   - `.jpg` for photographs
   - `.png` for graphics with transparency
3. **Responsive images**: Use CSS `max-width: 100%` for mobile compatibility
4. **Alt text**: Always include descriptive alt text for accessibility

### CSS Styling

Custom pages inherit your site's theme styling. You can add inline styles or reference CSS classes:

```html
<img src="/pages/about/images/hero.jpg" 
     alt="Hero image" 
     style="width: 100%; height: 400px; object-fit: cover; border-radius: 12px;">
```

## Security

Image serving includes the same security measures as gallery images:

- **Path traversal protection**: Prevents access to files outside the pages directory
- **File extension validation**: Only allows approved image formats
- **Filename validation**: Blocks potentially dangerous filenames

## Troubleshooting

### Images Not Loading

1. **Check file path**: Ensure the path matches your page slug exactly
2. **Verify file exists**: Confirm the image file is in the correct directory
3. **Check file extension**: Only `.jpg`, `.jpeg`, `.png`, and `.webp` are supported
4. **Use absolute paths**: Always start paths with `/pages/`

### Common Path Issues

❌ **Wrong:**
```html
<img src="images/photo.jpg">          <!-- Relative path -->
<img src="/images/photo.jpg">         <!-- Missing /pages -->
<img src="/pages/images/photo.jpg">   <!-- Missing page slug -->
```

✅ **Correct:**
```html
<img src="/pages/about/images/photo.jpg">    <!-- Full absolute path -->
<img src="/pages/about/photo.jpg">           <!-- Direct in page directory -->
```

## Best Practices

1. **Organize by page**: Keep each page's images in its own directory
2. **Use descriptive filenames**: `hero-image.jpg` instead of `img1.jpg`
3. **Optimize images**: Compress before uploading to reduce load times
4. **Include alt text**: Essential for accessibility and SEO
5. **Test responsive behavior**: Ensure images work well on mobile devices
6. **Use appropriate sizing**: Don't force large images into small containers