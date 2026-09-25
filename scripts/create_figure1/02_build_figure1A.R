# ==============================================================================
# Script: Build Figure 1A
# Purpose: genomic tracks of the peak sets and overlap groups, reduce | disjoin
# Input: BED files from script 01
# ==============================================================================

library(tidyverse)
library(plotgardener)
library(here)

# ==============================================================================
# Genomic window
# ==============================================================================
genomic_window <- "chr1:1-100,001"
bed_dir <- here("output", "overlaps_bed")

genomic_window_bis <- gsub(",", "", genomic_window)
split_window_coord <- str_split(pattern = ":", genomic_window_bis)
chr_i <- split_window_coord %>% map(1) %>% unlist
position_i <- split_window_coord %>% map(2) %>% unlist
start_i <- str_split(pattern = "-", position_i) %>% map(1) %>% unlist %>% as.numeric()
end_i <- str_split(pattern = "-", position_i) %>% map(2) %>% unlist %>% as.numeric()

output_file <- paste(sep = "_", "fig1A", chr_i, start_i, end_i)

# ==============================================================================
# Layout (inches)
# ==============================================================================
fontsize_val <- 7

# Narrower than the 178 mm of panels B and C, centred in the figure
width_mm  <- 130
width_val <- width_mm / 25.4

left_margin  <- 0.800   # row labels
right_margin <- 0.350   # mode bracket
track_w      <- width_val - left_margin - right_margin

# Row pitch must exceed the label line height
row_h       <- 0.070
row_gap     <- 0.035
regions_gap <- 0.090
block_gap   <- 0.190
top_y       <- 0.360
bot_margin  <- 0.130

axis_label_y <- 0.10
axis_line_y  <- 0.23

track_left  <- left_margin
track_right <- track_left + track_w
label_x     <- track_left - 0.06
bracket_x   <- track_right + 0.08
bracket_lab_x <- bracket_x + 0.10

# Binary notation, order set1/set2/set3; same palette as the Venn and UpSet panels
group_colors <- c(
    group_111 = "#D87093",
    group_110 = "#CD3301",
    group_101 = "#9370DB",
    group_011 = "#008B8B",
    group_100 = "#2B70AB",
    group_010 = "#FFB027",
    group_001 = "#3EA742"
)

groups_h <- length(group_colors) * row_h + (length(group_colors) - 1) * row_gap
block_h <- row_h + regions_gap + groups_h
peaks_bottom <- top_y + 2 * (row_h + row_gap) + row_h
height_val <- peaks_bottom + 2 * (block_gap + block_h) + bot_margin

message("Panel 1A: ", round(width_val * 25.4, 1), " x ",
        round(height_val * 25.4, 1), " mm")

params_i <- pgParams(
    chrom = chr_i,
    chromstart = start_i,
    chromend = end_i,
    x = track_left,
    just = c("left", "top"),
    width = track_w,
    length = track_w,
    default.units = "inches"
)

# ==============================================================================
# Helpers
# ==============================================================================
add_row_label <- function(label, y) {
    plotText(label = label,
             x = label_x, y = y + row_h / 2, just = c("right", "center"),
             fontsize = fontsize_val - 2, default.units = "inches")
}

# Regions row, seven group rows and a labelled bracket; returns the block bottom
draw_mode_block <- function(block_top, mode, prefix, regions_label,
                            alternate_shading = FALSE) {

    regions_y <- block_top
    regions_bed <- file.path(bed_dir, paste0(prefix, "_regions.bed"))

    if (alternate_shading) {
        # Disjoint regions touch, so alternate shades to separate them
        regions <- rtracklayer::import(regions_bed)
        GenomicRanges::mcols(regions)$region_id <- seq_along(regions) %% 2

        plotRanges(data = regions, params = params_i,
                   y = regions_y, height = row_h,
                   linecolor = NA,
                   collapse = TRUE,
                   fill = colorby("region_id",
                                  palette = colorRampPalette(c("#303030", "#D3D3D3"))))
    } else {
        plotRanges(data = regions_bed, params = params_i,
                   y = regions_y, height = row_h,
                   linecolor = NA, fill = "#303030", collapse = TRUE)
    }
    add_row_label(regions_label, regions_y)

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
# Output device
# ==============================================================================
# plotgardener draws on an open device, so saveViz() cannot be used here
output_dir <- here("output", "figure1")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
output_filepath <- file.path(output_dir, paste0(output_file, ".pdf"))

pdf(file = output_filepath, width = width_val, height = height_val)

pageCreate(width = width_val,
           height = height_val,
           default.units = "inches",
           showGuides = FALSE)

# ==============================================================================
# Genome axis
# ==============================================================================
# Manual axis so the labels sit above the line
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
# Peak sets
# ==============================================================================
for (i in 1:3) {
    peakset_y <- top_y + (i - 1) * (row_h + row_gap)

    plotRanges(data = here("input", "example_bed", paste0("peakset", i, ".bed")),
               params = params_i,
               y = peakset_y, height = row_h,
               linecolor = NA, fill = "darkgrey", collapse = TRUE)
    add_row_label(paste0("peakset", i), peakset_y)
}

# ==============================================================================
# Mode blocks
# ==============================================================================
reduce_bottom <- draw_mode_block(block_top = peaks_bottom + block_gap,
                                 mode = "reduce",
                                 prefix = "example_reduced",
                                 regions_label = "reduced regions")

draw_mode_block(block_top = reduce_bottom + block_gap,
                mode = "disjoin",
                prefix = "example_disjoint",
                regions_label = "disjoint regions",
                alternate_shading = TRUE)

dev.off()

message(" > Plot (pdf) saved in ", output_filepath)
