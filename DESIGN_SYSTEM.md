# Design System - Site da Sorte

## Project Overview
PWA application for displaying Brazilian lottery results using the Loterias CAIXA API.

## References
- **API Source**: [Loterias CAIXA API](https://github.com/guto-alves/loterias-api)
- **Design Guidelines**: [UI/UX Pro Max Skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)
- **API Endpoint**: https://loteriascaixa-api.herokuapp.com/api

## Color Palette

### Primary Colors
- **Dark Navy**: `#1E293D` - Primary backgrounds, headers
- **Ocean Blue**: `#006494` - Primary accent, buttons
- **Sky Blue**: `#247BA0` - Secondary accent, links
- **Light Blue**: `#1B98E0` - Highlights, active states
- **Ice White**: `#E8F1F2` - Light backgrounds, cards

### Neutral Colors
- **White**: `#FFFFFF` - Light backgrounds, text on dark
- **Light Gray**: `#F5F5F5` - Subtle backgrounds
- **Medium Gray**: `#9CA3AF` - Secondary text
- **Dark Gray**: `#374151` - Primary text
- **Black**: `#000000` - High contrast text

## Typography Rules

### Font Usage
- **Headings**: Use dark gray (#374151) or dark navy (#1E293D) on light backgrounds
- **Body Text**: Use dark gray (#374151) or medium gray (#9CA3AF)
- **Light Backgrounds**: Use dark text for maximum contrast
- **Dark Backgrounds**: Use white or ice white (#E8F1F2)

### Font Stack
```css
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
```

## Interface Guidelines

### Mobile-First Approach
1. Design for mobile (320px+) first
2. Progressively enhance for tablets (768px+)
3. Optimize for desktop (1024px+)

### Component Design Principles
1. **Simplicity**: Clean, uncluttered interfaces
2. **Accessibility**: WCAG AA compliance minimum
3. **Performance**: Fast loading, smooth animations
4. **Consistency**: Uniform spacing, colors, typography

### Color Application Rules

#### Backgrounds
- **Primary Background**: Ice White (#E8F1F2) or White (#FFFFFF)
- **Section Backgrounds**: Alternate between white and ice white
- **Header/Footer**: Dark Navy (#1E293D)
- **Cards**: White with subtle shadow

#### Interactive Elements
- **Primary Buttons**: Ocean Blue (#006494)
  - Hover: Sky Blue (#247BA0)
  - Active: Light Blue (#1B98E0)
- **Links**: Sky Blue (#247BA0)
  - Hover: Light Blue (#1B98E0)
- **Focus States**: Light Blue (#1B98E0) with 2px outline

#### Status Indicators
- **Success**: Keep palette - use Sky Blue (#247BA0)
- **Info**: Light Blue (#1B98E0)
- **Warning**: Use medium gray for subtle warnings
- **Error**: Use black for critical errors (avoid red to stay within palette)

### Spacing System
- **Base Unit**: 4px
- **Spacing Scale**: 4, 8, 12, 16, 24, 32, 48, 64px
- **Consistent Padding**: Use multiples of 4px
- **Vertical Rhythm**: Maintain consistent line-height

### Shadows
```css
/* Card Shadow */
box-shadow: 0 2px 8px rgba(30, 41, 61, 0.1);

/* Elevated Shadow */
box-shadow: 0 4px 16px rgba(30, 41, 61, 0.15);

/* Hover Shadow */
box-shadow: 0 8px 24px rgba(30, 41, 61, 0.2);
```

### Border Radius
- **Small**: 4px - Buttons, tags
- **Medium**: 8px - Cards, inputs
- **Large**: 16px - Modal dialogs, hero sections

### Animations
- **Duration**: 150-300ms
- **Easing**: cubic-bezier(0.4, 0.0, 0.2, 1)
- **Respect**: prefers-reduced-motion

## Component Specifications

### Lottery Card
- Background: White (#FFFFFF)
- Border: 1px solid Ice White (#E8F1F2)
- Border Radius: 8px
- Padding: 16px
- Shadow: Card shadow
- Title Color: Dark Navy (#1E293D)
- Numbers Background: Ocean Blue (#006494)
- Numbers Text: White (#FFFFFF)

### Next Draw Info
- Background: Light Blue (#1B98E0) gradient to Sky Blue (#247BA0)
- Text Color: White (#FFFFFF)
- Border Radius: 12px
- Padding: 16px
- Font Weight: 600

### Header
- Background: Dark Navy (#1E293D)
- Text Color: White (#FFFFFF)
- Logo Accent: Light Blue (#1B98E0)
- Height: 64px mobile, 80px desktop

### Footer
- Background: Dark Navy (#1E293D)
- Text Color: Ice White (#E8F1F2)
- Links Color: Sky Blue (#247BA0)
- Padding: 24px vertical

## Accessibility Requirements

1. **Color Contrast**: Minimum 4.5:1 for text
2. **Focus Indicators**: Visible on all interactive elements
3. **Keyboard Navigation**: Full keyboard support
4. **Screen Readers**: Semantic HTML, ARIA labels
5. **Touch Targets**: Minimum 44x44px for mobile

## Responsive Breakpoints

```css
/* Mobile First */
@media (min-width: 640px) { /* sm */ }
@media (min-width: 768px) { /* md */ }
@media (min-width: 1024px) { /* lg */ }
@media (min-width: 1280px) { /* xl */ }
```

## Anti-Patterns to Avoid

1. ❌ Using colors outside the defined palette
2. ❌ Light text on light backgrounds
3. ❌ Inconsistent spacing
4. ❌ Missing hover/focus states
5. ❌ Non-responsive layouts
6. ❌ Poor contrast ratios
7. ❌ Excessive animations
8. ❌ Missing loading states

## PWA Requirements

1. **Manifest**: Complete with icons, theme colors
2. **Service Worker**: Cache API responses and assets
3. **Offline Support**: Show cached results when offline
4. **Install Prompt**: Native app-like installation
5. **Performance**: Lighthouse score 90+
