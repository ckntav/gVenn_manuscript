# ==============================================================================
# Script: Build Figure 1B and 1C - Venn Diagram and UpSet plot
# Purpose: Create two complementary visualizations of peak set overlaps:
#          - Figure 1B: Traditional Venn diagram (good for 2-3 sets)
#          - Figure 1C: UpSet plot (better for 3+ sets, shows combinations clearly)
# ==============================================================================

# Load required packages
library(gVenn)         # For computing and visualizing set overlaps
library(GenomicRanges) # For working with genomic intervals
library(here)          # For robust file path construction

# ==============================================================================
# Import example data
# ==============================================================================
# Import the same three demonstration BED files used in script 01
# These contain genomic peak regions that will be analyzed for overlaps
peakset1 <- rtracklayer::import(here("input", "example_bed", "peakset1.bed"))
peakset2 <- rtracklayer::import(here("input", "example_bed", "peakset2.bed"))
peakset3 <- rtracklayer::import(here("input", "example_bed", "peakset3.bed"))

# ==============================================================================
# Organize data
# ==============================================================================
# Combine into a named GRangesList for analysis
# Each element represents one peak set
demo_peaks <- GRangesList("peakset1" = peakset1,
                          "peakset2" = peakset2,
                          "peakset3" = peakset3)

# Display the number of peaks in each set
# Provides a quick summary of input data size
sapply(demo_peaks, length)

# ==============================================================================
# Compute overlaps
# ==============================================================================
# Calculate all possible overlap combinations between the three peak sets
# This identifies which regions are shared or unique
ov <- computeOverlaps(demo_peaks)

# ==============================================================================
# Figure 1B: Create Venn Diagram
# ==============================================================================
# Generate a traditional Venn diagram showing set overlaps
# Venn diagrams are intuitive but become cluttered with >3 sets
venn <- plotVenn(ov)

# Display the plot (in RStudio or other graphics device)
venn

# Save the Venn diagram as a high-quality image file
# Supports multiple formats: png, pdf, svg, tiff, jpeg
saveViz(venn,
        output_dir = here("output", "figure1"),  # Output directory
        output_file = "fig1B_example_venn",      # Filename (without extension)
        with_date = FALSE,                        # Don't append date to filename
        width = 4,                                # Width in inches
        height = 2.5)                             # Height in inches

# ==============================================================================
# Figure 1C: Create UpSet plot
# ==============================================================================
# Generate an UpSet plot - a more scalable alternative to Venn diagrams
# UpSet plots use a matrix layout to show all possible set combinations
# This is especially useful when working with many sets (4+) or complex overlaps

upset <- plotUpSet(ov,
                   # Custom color palette matching the Venn diagram colors
                   comb_col = c( "#D87093",  "#CD3301", "#9370DB", "#008B8B", "#2B70AB", "#FFB027", "#3EA742"))

# Save the UpSet plot
# UpSet plots typically need more width to accommodate the matrix layout
saveViz(upset,
        output_dir = here("output", "figure1"),  # Output directory
        output_file = "fig1C_example_upset",     # Filename (without extension)
        with_date = FALSE,                        # Don't append date to filename
        width = 5,                                # Slightly wider than Venn diagram
        height = 3)                               # Taller to show the bar chart

# ==============================================================================
# Visualization comparison:
# 
# Venn Diagram (Figure 1B):
# - Pros: Intuitive, shows spatial relationships, familiar to most readers
# - Cons: Becomes cluttered with >3 sets, area sizes not always proportional
# - Best for: 2-3 sets, general audience
#
# UpSet Plot (Figure 1C):
# - Pros: Scales to many sets, exact counts displayed, shows all combinations
# - Cons: Less intuitive initially, requires explanation for some readers
# - Best for: 4+ sets, detailed quantitative comparisons
#
# Both use the same color scheme to maintain consistency across figures
# ==============================================================================