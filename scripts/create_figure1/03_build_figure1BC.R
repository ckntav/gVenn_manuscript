setwd("/Users/chris/Desktop/20251013_A549_gVenn")

# Load required packages
library(gVenn)
library(rtracklayer)

# Import the demonstration BED files
peakset1 <- rtracklayer::import("output/mock_bed/peakset1.bed")
peakset2 <- rtracklayer::import("output/mock_bed/peakset2.bed")
peakset3 <- rtracklayer::import("output/mock_bed/peakset3.bed")

# Combine into a GRangesList
demo_peaks <- GRangesList("peakset1" = peakset1,
                          "peakset2" = peakset2,
                          "peakset3" = peakset3)

sapply(demo_peaks, length)

# ========== COMPUTE OVERLAPS ==========
ov <- computeOverlaps(demo_peaks)

# Visualize with Venn diagram
venn <-
plotVenn(ov)

saveViz(venn,
        output_dir = "output/analysis/dataviz",
        output_file = "example_venn",
        width = 4, height = 2.5)

# Visualize with UpSet plot (better for 3+ sets)
upset <-
plotUpSet(ov,
          comb_col = c( "#D87093",  "#CD3301", "#9370DB", "#008B8B", "#2B70AB", "#FFB027", "#3EA742"))

saveViz(upset,
        output_dir = "output/analysis/dataviz",
        output_file = "example_upset",
        width = 5, height = 3)

# Get reduced regions (merged overlapping areas)
demo_reduced_regions <- ov$reduced_regions
cat("Total reduced regions:", length(demo_reduced_regions), "\n")
rtracklayer::export(demo_reduced_regions, format = "bed", con = "output/mock_bed/example_reduced_regions.bed")

# Extract all overlap groups
overlapGroups <- extractOverlaps(ov)
cat("\nOverlap group sizes:\n")
sapply(overlapGroups, length)

#
exportOverlapsToBed(overlapGroups,
                    output_dir = "output/mock_bed",
                    output_prefix = "example",
                    with_date = FALSE)