# ==============================================================================
# Script: Generate hex sticker for gVenn package
# Purpose: Create professional hexagonal sticker logos for the gVenn R package
#          using the Venn diagram generated in the previous script
#          (01_generate_pretty_venn_logo.R)
# ==============================================================================

library(hexSticker) # For creating hexagonal package stickers
                    # Install with: devtools::install_github("GuangchuangYu/hexSticker")
library(showtext)   # For custom font rendering in R graphics
library(here)       # For robust, portable file path construction

# ==============================================================================
# Font setup
# ==============================================================================
# Add custom Century Gothic font from local file
# This ensures the sticker has consistent, professional typography
font_add("Century Gothic", regular = here("input", "fonts", "centurygothic.ttf"))

# Enable showtext for automatic font rendering in graphics devices
showtext_auto()

# ==============================================================================
# Input image path
# ==============================================================================
# Path to the Venn diagram image created by the previous script
# This will be the central image on the hex sticker
imgurl <- here("output", "hex_sticker_logo", "venn_logo.png")

# ==============================================================================
# version 1: Basic hex sticker (without URL)
# ==============================================================================
sticker(imgurl, 
        package = "gVenn",           # Package name to display
        
        # Package name positioning
        p_x = 1,                     # X position (1 = center horizontally)
        p_y = 0.45,                  # Y position (lower values = bottom)
        
        # Subplot (Venn diagram) positioning  
        s_x = 1,                     # X position (1 = center horizontally)
        s_y = 1.2,                   # Y position (higher values = top)
        s_width = 0.55,              # Width of the subplot (0-1 scale)
        
        # Package name styling
        p_family = "Century Gothic", # Font family for package name
        p_size = 36,                 # Font size for package name
        p_color = "black",           # Text color for package name
        
        # Hexagon styling
        h_fill = "white",            # Background fill color of hexagon
        h_size = 1.2,                # Border thickness of hexagon
        h_color = "black",           # Border color of hexagon
        
        # Output settings
        dpi = 600,                   # High resolution for print quality
        filename = here("output", "hex_sticker_logo", "gVenn_hex_sticker.png"))

# ==============================================================================
# version 2: Hex sticker with GitHub URL
# ==============================================================================
# This version includes the package's GitHub URL at the bottom
sticker(imgurl, 
        package = "gVenn",           # Package name to display
        
        # Package name positioning (same as version 1)
        p_x = 1,                     # X position (1 = center horizontally)
        p_y = 0.45,                  # Y position (lower values = bottom)
        
        # Subplot (Venn diagram) positioning (same as version 1)
        s_x = 1,                     # X position (1 = center horizontally)
        s_y = 1.2,                   # Y position (higher values = top)
        s_width = 0.55,              # Width of the subplot (0-1 scale)
        
        # Package name styling (same as version 1)
        p_family = "Century Gothic", # Font family for package name
        p_size = 36,                 # Font size for package name
        p_color = "black",           # Text color for package name
        
        # Hexagon styling (same as version 1)
        h_fill = "white",            # Background fill color of hexagon
        h_size = 1.2,                # Border thickness of hexagon
        h_color = "black",           # Border color of hexagon
        
        # Output settings
        dpi = 600,                   # High resolution for print quality
        
        # URL settings (NEW in this version)
        url = "github.com/ckntav/gVenn",  # GitHub repository URL
        u_color = "#303030",         # Dark gray color for URL text
        u_size = 5,                  # Font size for URL
        u_family = "Century Gothic", # Font family for URL (matches package name)
        
        # Output file with URL version
        filename = here("output", "hex_sticker_logo", "gVenn_hex_sticker_with_url.png"))