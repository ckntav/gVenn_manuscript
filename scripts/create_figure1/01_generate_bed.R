# Load required packages
library(gVenn)
library(GenomicRanges)
library(here)

# Import the demonstration BED files
peakset1 <- rtracklayer::import(here("input", "example_bed", "peakset1.bed"))
peakset2 <- rtracklayer::import(here("input", "example_bed", "peakset2.bed"))
peakset3 <- rtracklayer::import(here("input", "example_bed", "peakset3.bed"))

# Combine into a GRangesList
demo_peaks <- GRangesList("peakset1" = peakset1,
                          "peakset2" = peakset2,
                          "peakset3" = peakset3)

sapply(demo_peaks, length)

# ========== COMPUTE OVERLAPS ==========
ov <- computeOverlaps(demo_peaks)

# Get reduced regions (merged overlapping areas)
demo_reduced_regions <- ov$reduced_regions
message("Total number of reduced regions:", length(demo_reduced_regions))
rtracklayer::export(demo_reduced_regions, format = "bed", con = here("output", "overlaps_bed", "example_reduced_regions.bed"))

# Extract all overlap groups
overlapGroups <- extractOverlaps(ov)
sapply(overlapGroups, length)

#
exportOverlapsToBed(overlapGroups,
                    output_dir = here("output", "overlaps_bed"),
                    output_prefix = "example",
                    with_date = FALSE)