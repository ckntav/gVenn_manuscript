library(tidyverse)
library(plotgardener)
library(here)

genomic_window <- "chr1:1-100,001"

#
width_val <- 3.7
height_val <- 1.9
fontsize_val <- 5
height_track <- 0.2

#
# retrieve genomic coordinates
genomic_window_bis <- gsub(",", "", genomic_window)
split_window_coord <- str_split(pattern = ":", genomic_window_bis)
chr_i <- split_window_coord %>% map(1) %>% unlist
position_i <- split_window_coord %>% map(2) %>% unlist
start_i <- str_split(pattern = "-", position_i) %>% map(1) %>% unlist %>% as.numeric()
end_i <- str_split(pattern = "-", position_i) %>% map(2) %>% unlist %>% as.numeric()
output_file <- paste(sep = "_", "fig1A", chr_i, start_i, end_i)

#
params_i <- pgParams(
    chrom = chr_i, chromstart = start_i, chromend = end_i,
    # assembly = hg38_ensembl104,
    # assembly = ensembl104,
    x = 0.5, just = c("left", "top"),
    width = width_val-1, length = width_val-1, default.units = "inches"
)

#
output_dir <- here("output", "figure1")
output_filepath <- file.path(output_dir, paste0(output_file, ".pdf"))
pdf(file = output_filepath, width = width_val, height = height_val)

# Create pages
pageCreate(width = width_val, height = height_val, default.units = "inches", showGuides = FALSE)

#
#
plotRanges(data = here("input", "example_bed", "peakset1.bed"), params = params_i,
           y = 0.3, height = 0.065,
           linecolor = NA, fill = "darkgrey", collapse = TRUE)
plotText(label = "peakset1", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

#
plotRanges(data = here("input", "example_bed", "peakset2.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "darkgrey", collapse = TRUE)
plotText(label = "peakset2", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

#
plotRanges(data = here("input", "example_bed", "peakset3.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "darkgrey", collapse = TRUE)
plotText(label = "peakset3", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

#
plotRanges(data = here("output", "overlaps_bed", "example_reduced_regions.bed"), params = params_i,
           y = "0.15b", height = 0.065,
           linecolor = NA, fill = "#303030", collapse = TRUE)
plotText(label = "reduced regions", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

#
plotRanges(data = here("output", "overlaps_bed", "example_group_111.bed"), params = params_i,
           y = "0.15b", height = 0.065,
           linecolor = NA, fill = "#D87093", collapse = TRUE)
plotText(label = "group_111", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

#
plotRanges(data = here("output", "overlaps_bed", "example_group_110.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "#CD3301", collapse = TRUE)
plotText(label = "group_110", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

#
plotRanges(data = here("output", "overlaps_bed", "example_group_101.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "#9370DB", collapse = TRUE)
plotText(label = "group_101", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

#
plotRanges(data = here("output", "overlaps_bed", "example_group_011.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "#008B8B", collapse = TRUE)
plotText(label = "group_011", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

#
plotRanges(data = here("output", "overlaps_bed", "example_group_100.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "#2B70AB", collapse = TRUE)
plotText(label = "group_100", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

#
plotRanges(data = here("output", "overlaps_bed", "example_group_010.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "#FFB027", collapse = TRUE)
plotText(label = "group_010", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

#
plotRanges(data = here("output", "overlaps_bed", "example_group_001.bed"), params = params_i,
           y = "0.03b", height = 0.065,
           linecolor = NA, fill = "#3EA742", collapse = TRUE)
plotText(label = "group_001", x = 0.45, y = "-0.035b", fontsize = fontsize_val-2, just = "right")

##### Plot genome label
plotGenomeLabel(params = params_i,
                # assembly = ensembl104,
                assembly = "hg38",
                y = "0.1b", scale = "bp",
                fontcolor = "#404040", linecolor = "#404040",
                fontsize = fontsize_val,
                boxWidth = 0.2)

## Hide page guides
# pageGuideHide()

dev.off()
message(" > Plot (pdf) saved in ", output_filepath)
