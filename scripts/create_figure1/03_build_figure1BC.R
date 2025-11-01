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

# Visualize with Venn diagram
venn <- plotVenn(ov)
venn

saveViz(venn,
        output_dir = here("output", "figure1"),
        output_file = "fig1B_example_venn",
        with_date = FALSE,
        width = 4, height = 2.5)

# Visualize with UpSet plot (better for 3+ sets)
upset <- plotUpSet(ov,
                   comb_col = c( "#D87093",  "#CD3301", "#9370DB", "#008B8B", "#2B70AB", "#FFB027", "#3EA742"))

saveViz(upset,
        output_dir = here("output", "figure1"),
        output_file = "fig1C_example_upset",
        with_date = FALSE,
        width = 5, height = 3)