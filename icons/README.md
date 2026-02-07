# PWA Icons

## Required Sizes

This folder should contain the following icon sizes for optimal PWA support:

- icon-72x72.png
- icon-96x96.png
- icon-128x128.png
- icon-144x144.png
- icon-152x152.png
- icon-192x192.png
- icon-384x384.png
- icon-512x512.png

## Design Guidelines

### Colors
- Background: `#1E293D` (Dark Navy)
- Icon Color: `#1B98E0` (Light Blue) or `#FFFFFF` (White)

### Style
- Use simple, recognizable lottery-related icons
- Consider: clover, lottery ball, ticket, or number symbols
- Ensure good contrast for visibility
- Make it recognizable even at small sizes

## Creating Icons

### Option 1: Online Tools
- [PWA Icon Generator](https://www.pwabuilder.com/)
- [Favicon Generator](https://realfavicongenerator.net/)
- [App Icon Generator](https://appicon.co/)

### Option 2: Design Software
1. Create a 512x512 base icon in Figma/Photoshop/Illustrator
2. Export at all required sizes
3. Ensure proper padding (safe area)

### Option 3: Simple SVG Base

```svg
<svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
  <rect width="512" height="512" fill="#1E293D"/>
  <circle cx="256" cy="256" r="200" fill="#1B98E0"/>
  <text x="256" y="300" font-size="200" fill="#FFFFFF" text-anchor="middle" font-family="Arial" font-weight="bold">$</text>
</svg>
```

Convert this SVG to PNG at different sizes using online tools or ImageMagick:

```bash
# Using ImageMagick
convert icon.svg -resize 72x72 icon-72x72.png
convert icon.svg -resize 96x96 icon-96x96.png
convert icon.svg -resize 128x128 icon-128x128.png
convert icon.svg -resize 144x144 icon-144x144.png
convert icon.svg -resize 152x152 icon-152x152.png
convert icon.svg -resize 192x192 icon-192x192.png
convert icon.svg -resize 384x384 icon-384x384.png
convert icon.svg -resize 512x512 icon-512x512.png
```

## Testing

After adding icons:
1. Run the app
2. Open DevTools → Application → Manifest
3. Verify all icons are loading correctly
4. Test installation on different devices
