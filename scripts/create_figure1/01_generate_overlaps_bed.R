# ==============================================================================
# Script: Generate BED Files for Figure 1
# Purpose: compute overlaps in "reduce" and "disjoin" modes, export groups as BED
# ==============================================================================

library(gVenn)
library(GenomicRanges)
library(here)

# ==============================================================================
# Import data
# ==============================================================================
peakset1 <- rtracklayer::import(here("input", "example_bed", "peakset1.bed"))
peakset2 <- rtracklayer::import(here("input", "example_bed", "peakset2.bed"))
peakset3 <- rtracklayer::import(here("input", "example_bed", "peakset3.bed"))

demo_peaks <- GRangesList("peakset1" = peakset1,
                          "peakset2" = peakset2,
                          "peakset3" = peakset3)

sapply(demo_peaks, length)

# ==============================================================================
# Output directory
# ==============================================================================
# export() does not create missing directories
output_dir <- here("output", "overlaps_bed")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# ==============================================================================
# Compute and export overlaps
# ==============================================================================
modes <- list(
    list(mode = "reduce",  prefix = "example_reduced",  label = "reduced"),
    list(mode = "disjoin", prefix = "example_disjoint", label = "disjoint")
)

for (cfg in modes) {

    message("\n=== computeOverlaps(mode = \"", cfg$mode, "\") ===")

    ov <- computeOverlaps(demo_peaks, mode = cfg$mode)

    regions <- ov$regions
    message("Total number of ", cfg$label, " regions: ", length(regions))

    rtracklayer::export(regions,
                        format = "bed",
                        con = file.path(output_dir,
                                        paste0(cfg$prefix, "_regions.bed")))

    overlapGroups <- extractOverlaps(ov)
    print(sapply(overlapGroups, length))

    # Writes <prefix>_group_111.bed ... <prefix>_group_001.bed
    exportOverlapsToBed(overlapGroups,
                        output_dir = output_dir,
                        output_prefix = cfg$prefix,
                        with_date = FALSE)
}
