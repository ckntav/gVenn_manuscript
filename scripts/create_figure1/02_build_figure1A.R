# ==============================================================================
# Script: Build Figure 1A - Genomic Track Visualization
# Purpose: Create a publication-quality genomic browser-style visualization
#          showing three peak sets and their overlap groups across a genomic
#          region, for BOTH partitioning modes of gVenn::computeOverlaps()
# Note:    The two blocks below share the same peak sets and the same genomic
#          axis, so the effect of the mode can be read off directly:
#          - "reduce"  merges overlapping peaks within each set before
#            intersecting them, so every region belongs to a single group
#          - "disjoin" cuts the peaks at every boundary, so a single peak can be
#            split across several groups
#          The BED files plotted here are produced by script 01
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

# Directory holding the BED files written by script 01
bed_dir <- here("output", "overlaps_bed")

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
# Set plot dimensions and styling
# ==============================================================================
fontsize_val <- 7       # Base font size for labels

# ------------------------------------------------------------------------------
# Horizontal layout
# ------------------------------------------------------------------------------
# Journal limits: 84 mm for a single column, 178 mm for a double column, and
# 230 mm of height. Figure 1 is assembled as panels A / B / C stacked
# vertically in a double-column figure; B and C each hold two plots side by
# side and take the full 178 mm, while panel A stays deliberately narrower and
# is centred. Set the target width here, everything else follows from it
width_mm  <- 130
width_val <- width_mm / 25.4   # Width of the entire plot in inches

# The width is split into three columns: the row labels on the left, the
# genomic tracks in the middle, and the mode brackets on the right
left_margin  <- 0.800   # Space reserved for the row labels
right_margin <- 0.350   # Space for the mode bracket and its rotated label
track_w      <- width_val - left_margin - right_margin  # Genomic tracks

# ------------------------------------------------------------------------------
# Vertical layout
# ------------------------------------------------------------------------------
# All row positions are computed in inches rather than with plotgardener's
# relative "b" (below) units: with two stacked blocks the absolute positions make
# the layout easier to reason about, and they let the page height be derived
# from the content instead of being hard-coded
# The row pitch (row_h + row_gap) has to stay above the line height of a row
# label, otherwise consecutive labels collide
row_h       <- 0.070    # Height of one genomic track row
row_gap     <- 0.035    # Vertical gap between two consecutive rows
regions_gap <- 0.090    # Extra gap between a "regions" row and its overlap groups
block_gap   <- 0.190    # Gap before each mode block
top_y       <- 0.360    # Top of the first peak set row
bot_margin  <- 0.130    # Free space below the last row

axis_label_y <- 0.10    # Top of the coordinate labels
axis_line_y  <- 0.23    # Vertical position of the axis line

track_left  <- left_margin              # Left edge of the genomic tracks
track_right <- track_left + track_w     # Right edge of the genomic tracks
label_x     <- track_left - 0.06        # Right edge of the row labels
bracket_x   <- track_right + 0.08       # Vertical bar marking a mode block
bracket_lab_x <- bracket_x + 0.10       # Rotated "mode = ..." label

# ==============================================================================
# Overlap groups and their colors
# ==============================================================================
# Binary notation: 1 = present, 0 = absent (order: set1, set2, set3)
# The same palette is used for both blocks and matches the Venn / UpSet panels
group_colors <- c(
    group_111 = "#D87093",  # Present in all three sets (pink)
    group_110 = "#CD3301",  # Present in sets 1 and 2, absent in set 3 (red)
    group_101 = "#9370DB",  # Present in sets 1 and 3, absent in set 2 (purple)
    group_011 = "#008B8B",  # Present in sets 2 and 3, absent in set 1 (teal)
    group_100 = "#2B70AB",  # Unique to set 1 (blue)
    group_010 = "#FFB027",  # Unique to set 2 (orange)
    group_001 = "#3EA742"   # Unique to set 3 (green)
)

# ==============================================================================
# Derive the page height from the layout
# ==============================================================================
# Height of the 7 stacked overlap group rows
groups_h <- length(group_colors) * row_h + (length(group_colors) - 1) * row_gap

# Height of one mode block: regions row + gap + overlap groups
block_h <- row_h + regions_gap + groups_h

# Bottom of the three peak set rows
peaks_bottom <- top_y + 2 * (row_h + row_gap) + row_h

# Total page height: peak sets + two mode blocks (each preceded by a gap)
height_val <- peaks_bottom + 2 * (block_gap + block_h) + bot_margin

# Report the panel size in mm, to check it against the journal limits
# (84 mm single column / 178 mm double column, 230 mm maximum height)
message("Panel 1A: ", round(width_val * 25.4, 1), " x ",
        round(height_val * 25.4, 1), " mm")

# ==============================================================================
# Set Up Plot Parameters
# ==============================================================================
# Create a parameter object that will be reused for all genomic tracks
# This ensures consistent positioning and scaling across all tracks
params_i <- pgParams(
    chrom = chr_i,              # Chromosome to display
    chromstart = start_i,       # Start position of window
    chromend = end_i,           # End position of window
    x = track_left,             # X position on page (in inches from left)
    just = c("left", "top"),    # Justification for positioning
    width = track_w,            # Width of genomic tracks (slightly less than page)
    length = track_w,           # Length parameter (used for some plot types)
    default.units = "inches"    # Units for measurements
)

# ==============================================================================
# Helper functions
# ==============================================================================
# Write the label of a track row, vertically centered on the row
add_row_label <- function(label, y) {
    plotText(label = label,
             x = label_x, y = y + row_h / 2, just = c("right", "center"),
             fontsize = fontsize_val - 2, default.units = "inches")
}

# Draw one complete mode block: the partitioned regions produced by the mode,
# then the seven overlap groups, with a vertical bar on the right spanning the
# whole block and labelled with the mode that produced it
# `block_top` is the top of the block; the function returns the block bottom
draw_mode_block <- function(block_top, mode, prefix, regions_label,
                            alternate_shading = FALSE) {

    # ---------------------------------------------------------------------------
    # Partitioned regions
    # ---------------------------------------------------------------------------
    # All regions covered by at least one peak, partitioned according to the mode
    regions_y <- block_top
    regions_bed <- file.path(bed_dir, paste0(prefix, "_regions.bed"))

    if (alternate_shading) {
        # In "disjoin" mode adjacent regions often touch each other, so an
        # alternating shade is needed to tell them apart
        regions <- rtracklayer::import(regions_bed)
        GenomicRanges::mcols(regions)$region_id <- seq_along(regions) %% 2

        plotRanges(data = regions, params = params_i,
                   y = regions_y, height = row_h,
                   linecolor = NA,
                   collapse = TRUE,
                   fill = colorby("region_id",
                                  palette = colorRampPalette(c("#303030", "#D3D3D3"))))
    } else {
        # In "reduce" mode the regions are merged and well separated
        plotRanges(data = regions_bed, params = params_i,
                   y = regions_y, height = row_h,
                   linecolor = NA, fill = "#303030", collapse = TRUE)
    }
    add_row_label(regions_label, regions_y)

    # ---------------------------------------------------------------------------
    # Individual overlap groups
    # ---------------------------------------------------------------------------
    # Each overlap group is color-coded to match the Venn diagram colors
    groups_y <- regions_y + row_h + regions_gap

    for (i in seq_along(group_colors)) {
        group_name <- names(group_colors)[i]
        group_y <- groups_y + (i - 1) * (row_h + row_gap)

        plotRanges(data = file.path(bed_dir, paste0(prefix, "_", group_name, ".bed")),
                   params = params_i,
                   y = group_y, height = row_h,
                   linecolor = NA, fill = group_colors[[i]], collapse = TRUE)
        add_row_label(group_name, group_y)
    }

    # ---------------------------------------------------------------------------
    # Mode bracket
    # ---------------------------------------------------------------------------
    # A vertical bar spanning the regions row and the seven overlap groups,
    # labelled with the computeOverlaps() mode that produced them
    block_bottom <- groups_y + groups_h

    plotSegments(x0 = bracket_x, y0 = block_top,
                 x1 = bracket_x, y1 = block_bottom,
                 default.units = "inches", linecolor = "#404040", lwd = 0.75)

    plotText(label = paste0('mode = "', mode, '"'),
             x = bracket_lab_x, y = mean(c(block_top, block_bottom)),
             just = "center", rot = 270,
             fontsize = fontsize_val - 1,
             fontface = "italic",
             fontcolor = "#404040",
             default.units = "inches")

    invisible(block_bottom)
}

# ==============================================================================
# Initialize PDF output
# ==============================================================================
# plotgardener draws directly onto an open graphics device instead of returning a
# plot object, so the PDF device is opened here rather than using gVenn::saveViz()
output_dir <- here("output", "figure1")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

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
# Add genome coordinate axis (top of the panel)
# ==============================================================================
# Drawn manually rather than with plotGenomeLabel() so that the coordinate
# labels sit above the axis line, with the tracks hanging underneath
plotText(label = paste(format(start_i, big.mark = ",", scientific = FALSE), "bp"),
         x = track_left, y = axis_label_y, just = c("left", "top"),
         fontsize = fontsize_val, fontcolor = "#404040", default.units = "inches")
plotText(label = chr_i,
         x = mean(c(track_left, track_right)), y = axis_label_y, just = c("center", "top"),
         fontsize = fontsize_val, fontcolor = "#404040", default.units = "inches")
plotText(label = paste(format(end_i, big.mark = ",", scientific = FALSE), "bp"),
         x = track_right, y = axis_label_y, just = c("right", "top"),
         fontsize = fontsize_val, fontcolor = "#404040", default.units = "inches")

plotSegments(x0 = track_left, y0 = axis_line_y,
             x1 = track_right, y1 = axis_line_y,
             default.units = "inches", linecolor = "#404040", lwd = 0.75)

# ==============================================================================
# Plot Original Peak Sets
# ==============================================================================
# The three input peak sets, shared by both mode blocks below
for (i in 1:3) {
    peakset_y <- top_y + (i - 1) * (row_h + row_gap)

    plotRanges(data = here("input", "example_bed", paste0("peakset", i, ".bed")),
               params = params_i,
               y = peakset_y, height = row_h,
               linecolor = NA, fill = "darkgrey", collapse = TRUE)
    add_row_label(paste0("peakset", i), peakset_y)
}

# ==============================================================================
# Block 1: "reduce" mode
# ==============================================================================
reduce_bottom <- draw_mode_block(block_top = peaks_bottom + block_gap,
                                 mode = "reduce",
                                 prefix = "example_reduced",
                                 regions_label = "reduced regions")

# ==============================================================================
# Block 2: "disjoin" mode
# ==============================================================================
draw_mode_block(block_top = reduce_bottom + block_gap,
                mode = "disjoin",
                prefix = "example_disjoint",
                regions_label = "disjoint regions",
                alternate_shading = TRUE)

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
# 1. Genomic coordinate axis at top
# 2. Three original peak sets (darkgrey)
# 3. "reduce" block: merged reduced regions (dark gray) and the seven overlap
#    groups color-coded by presence/absence pattern
# 4. "disjoin" block: disjoint regions (alternating shades to separate adjacent
#    intervals) and the same seven overlap groups
# 5. A vertical bar on the right of each block, labelled with the mode that
#    produced the rows it spans
# ==============================================================================
