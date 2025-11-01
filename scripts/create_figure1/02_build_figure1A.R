# ==============================================================================
# Script: Build Figure 1A - Genomic Track Visualization
# Purpose: Create a publication-quality genomic browser-style visualization
#          showing three peak sets and their overlap groups across a genomic region
# ==============================================================================

library(tidyverse)    # For data manipulation and string processing
library(plotgardener) # For creating publication-quality genomic visualizations
library(here)         # For robust file path construction

# ==============================================================================
# Define Genomic Window
# ==============================================================================
# Specify the genomic region to visualize (chr1:1-100,001)
# This window contains example peaks that demonstrate various overlap patterns
genomic_window <- "chr1:1-100,001"

# ==============================================================================
# Set plot dimensions and styling
# ==============================================================================
width_val <- 3.7        # Width of the entire plot in inches
height_val <- 1.9       # Height of the entire plot in inches
fontsize_val <- 5       # Base font size for labels

# ==============================================================================
# Parse Genomic Coordinates
# ==============================================================================
# Extract chromosome, start, and end positions from the genomic window string
genomic_window_bis <- gsub(",", "", genomic_window)
split_window_coord <- str_split(pattern = ":", genomic_window_bis)
chr_i <- split_window_coord %>% map(1) %>% unlist
position_i <- split_window_coord %>% map(2) %>% unlist
start_i <- str_split(pattern = "-", position_i) %>% map(1) %>% unlist %>% as.numeric()
end_i <- str_split(pattern = "-", position_i) %>% map(2) %>% unlist %>% as.numeric()

# Create descriptive output filename including coordinates
output_file <- paste(sep = "_", "fig1A", chr_i, start_i, end_i)

# ==============================================================================
# Set Up Plot Parameters
# ==============================================================================
# Create a parameter object that will be reused for all genomic tracks
# This ensures consistent positioning and scaling across all tracks
params_i <- pgParams(
    chrom = chr_i,              # Chromosome to display
    chromstart = start_i,       # Start position of window
    chromend = end_i,           # End position of window
    x = 0.5,                    # X position on page (in inches from left)
    just = c("left", "top"),    # Justification for positioning
    width = width_val - 1,      # Width of genomic tracks (slightly less than page)
    length = width_val - 1,     # Length parameter (used for some plot types)
    default.units = "inches"    # Units for measurements
)


# ==============================================================================
# Initialize PDF output
# ==============================================================================
# Create output directory path
output_dir <- here("output", "figure1")

# Construct full output file path
output_filepath <- file.path(output_dir, paste0(output_file, ".pdf"))

# Open PDF device for plotting
pdf(file = output_filepath, width = width_val, height = height_val)

# Create a new page with specified dimensions
pageCreate(width = width_val, 
           height = height_val, 
           default.units = "inches", 
           showGuides = FALSE)  # Don't show alignment guides

# ==============================================================================
# Plot Original Peak Sets
# ==============================================================================
# Plot peakset1 (first row)
plotRanges(data = here("input", "example_bed", "peakset1.bed"), params = params_i,
           y = 0.3, height = 0.065,
           linecolor = NA, fill = "darkgrey", collapse = TRUE)
plotText(label = "peakset1", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

# Plot peakset2 (second row)
plotRanges(data = here("input", "example_bed", "peakset2.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "darkgrey", collapse = TRUE)
plotText(label = "peakset2", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

# Plot peakset3 (third row)
plotRanges(data = here("input", "example_bed", "peakset3.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "darkgrey", collapse = TRUE)
plotText(label = "peakset3", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

# ==============================================================================
# Plot Reduced Regions (Merged Overlapping Areas)
# ==============================================================================
# Show all regions that contain at least one peak, merged into non-overlapping intervals
plotRanges(data = here("output", "overlaps_bed", "example_reduced_regions.bed"), params = params_i,
           y = "0.15b", height = 0.065,
           linecolor = NA, fill = "#303030", collapse = TRUE)
plotText(label = "reduced regions", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

# ==============================================================================
# Plot Individual Overlap Groups
# ==============================================================================
# Each overlap group is color-coded to match the Venn diagram colors
# Binary notation: 1 = present, 0 = absent (order: set1, set2, set3)

# Group 111: Present in all three sets (pink)
plotRanges(data = here("output", "overlaps_bed", "example_group_111.bed"), params = params_i,
           y = "0.15b", height = 0.065,
           linecolor = NA, fill = "#D87093", collapse = TRUE)
plotText(label = "group_111", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

# Group 110: Present in sets 1 and 2, absent in set 3 (red)
plotRanges(data = here("output", "overlaps_bed", "example_group_110.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "#CD3301", collapse = TRUE)
plotText(label = "group_110", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

# Group 101: Present in sets 1 and 3, absent in set 2 (purple)
plotRanges(data = here("output", "overlaps_bed", "example_group_101.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "#9370DB", collapse = TRUE)
plotText(label = "group_101", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

# Group 011: Present in sets 2 and 3, absent in set 1 (teal)
plotRanges(data = here("output", "overlaps_bed", "example_group_011.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "#008B8B", collapse = TRUE)
plotText(label = "group_011", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

# Group 100: Unique to set 1 (blue)
plotRanges(data = here("output", "overlaps_bed", "example_group_100.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "#2B70AB", collapse = TRUE)
plotText(label = "group_100", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

# Group 010: Unique to set 2 (orange)
plotRanges(data = here("output", "overlaps_bed", "example_group_010.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "#FFB027", collapse = TRUE)
plotText(label = "group_010", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

# Group 001: Unique to set 3 (green)
plotRanges(data = here("output", "overlaps_bed", "example_group_001.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "#3EA742", collapse = TRUE)
plotText(label = "group_001", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

# ==============================================================================
# Add genome coordinate axis
# ==============================================================================
# Plot a labeled axis showing genomic coordinates and scale
plotGenomeLabel(params = params_i,
                # assembly = ensembl104,
                assembly = "hg38",
                y = "0.1b", scale = "bp",
                fontcolor = "#404040", linecolor = "#404040",
                fontsize = fontsize_val,
                boxWidth = 0.2)

# ==============================================================================
# Finalize and save
# ==============================================================================
# Close the PDF device (saves the file)
dev.off()

# Print confirmation message with file path
message(" > Plot (pdf) saved in ", output_filepath)

# ==============================================================================
# Output:
# A multi-track genomic visualization showing:
# 1. Three original peak sets (darkgrey)
# 2. Merged reduced regions (dark gray)
# 3. Seven overlap groups color-coded by presence/absence pattern
# 4. Genomic coordinate axis at bottom
# ==============================================================================