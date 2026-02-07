#!/bin/bash

# Simple placeholder icon creator using SVG
# This creates basic icons for testing - replace with professional icons later

SIZES=(72 96 128 144 152 192 384 512)

# Create a base SVG template
create_svg() {
    local size=$1
    cat > "/home/user/SiteDaSorte/icons/icon-${size}x${size}.svg" <<EOF
<svg width="${size}" height="${size}" viewBox="0 0 ${size} ${size}" xmlns="http://www.w3.org/2000/svg">
  <!-- Background -->
  <rect width="${size}" height="${size}" fill="#1E293D" rx="$((size/8))"/>

  <!-- Circle -->
  <circle cx="$((size/2))" cy="$((size/2))" r="$((size*3/8))" fill="#1B98E0"/>

  <!-- Dollar symbol -->
  <text
    x="$((size/2))"
    y="$((size*5/8))"
    font-size="$((size/2))"
    fill="#FFFFFF"
    text-anchor="middle"
    font-family="Arial, sans-serif"
    font-weight="bold">$</text>
</svg>
EOF
    echo "Created icon-${size}x${size}.svg"
}

# Create all SVG sizes
for size in "${SIZES[@]}"; do
    create_svg "$size"
done

echo ""
echo "✅ Placeholder icons created successfully!"
echo ""
echo "Note: These are simple SVG placeholders."
echo "For production, please create professional PNG icons."
echo "See icons/README.md for detailed instructions."
