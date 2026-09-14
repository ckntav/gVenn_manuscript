# ==============================================================================
# Script: Generate BED Files for Figure 1
# Purpose: Process example genomic peak sets (BED files), compute their overlaps
#          in both partitioning modes, and export the overlap groups as separate
#          BED files for visualization
# Note:    Overlaps are computed with gVenn::computeOverlaps() in both modes:
#          - "reduce"  merges overlapping peaks within each set before
#            intersecting them, so every region belongs to a single overlap group
#          - "disjoin" splits the peaks into the smallest non-overlapping
#            intervals, so a single peak can be cut into several regions
#            assigned to different groups
#          Both are shown side by side in the new Figure 1
# ==============================================================================

# Load required packages
library(gVenn)         # For computing and visualizing set overlaps
library(GenomicRanges) # For working with genomic intervals (GRanges objects)
library(here)          # For robust file path construction

# ==============================================================================
# Import example data
# ==============================================================================
# Import three demonstration BED files containing genomic peak regions
# These could be from ChIP-seq, ATAC-seq, or other peak-calling experiments
peakset1 <- rtracklayer::import(here("input", "example_bed", "peakset1.bed"))
peakset2 <- rtracklayer::import(here("input", "example_bed", "peakset2.bed"))
peakset3 <- rtracklayer::import(here("input", "example_bed", "peakset3.bed"))

# ==============================================================================
# Organize Data
# ==============================================================================
# Combine the three peak sets into a GRangesList object
# GRangesList is a convenient structure for storing multiple sets of genomic ranges
# Each element is named to identify which peak set it represents
demo_peaks <- GRangesList("peakset1" = peakset1,
                          "peakset2" = peakset2,
                          "peakset3" = peakset3)

# Display the number of peaks in each set
# This provides a quick summary of the input data
sapply(demo_peaks, length)

# ==============================================================================
# Prepare the output directory
# ==============================================================================
# Both modes write into the same directory, distinguished by their file prefix
# rtracklayer::export() does not create missing directories, so make sure it exists
output_dir <- here("output", "overlaps_bed")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# ==============================================================================
# Describe the two overlap modes
# ==============================================================================
# Everything below is driven by this list, so the mode, the file prefix and the
# wording of the log messages are declared in a single place
modes <- list(
    list(mode = "reduce",  prefix = "example_reduced",  label = "reduced"),
    list(mode = "disjoin", prefix = "example_disjoint", label = "disjoint")
)

# ==============================================================================
# Compute and export the overlaps, one mode at a time
# ==============================================================================
for (cfg in modes) {

    message("\n=== computeOverlaps(mode = \"", cfg$mode, "\") ===")

    # --------------------------------------------------------------------------
    # Compute overlaps
    # --------------------------------------------------------------------------
    # Calculate all possible overlaps between the three peak sets
    # This identifies which regions are:
    # - Unique to one set
    # - Shared by exactly two sets
    # - Shared by all three sets
    ov <- computeOverlaps(demo_peaks, mode = cfg$mode)

    # --------------------------------------------------------------------------
    # Export the partitioned regions
    # --------------------------------------------------------------------------
    # Extract the regions produced by the chosen mode: the minimal merged
    # intervals in "reduce" mode, the elementary cut intervals in "disjoin" mode
    # Think of this as a "master set" of all distinct regions
    regions <- ov$regions

    # Report the total number of regions found
    message("Total number of ", cfg$label, " regions: ", length(regions))

    rtracklayer::export(regions,
                        format = "bed",
                        con = file.path(output_dir,
                                        paste0(cfg$prefix, "_regions.bed")))

    # --------------------------------------------------------------------------
    # Extract and Export Overlap Groups
    # --------------------------------------------------------------------------
    # Extract all overlap groups (e.g., regions in only set 1, only in sets 1&2, etc.)
    # Each group represents a different combination of overlapping peak sets
    overlapGroups <- extractOverlaps(ov)

    # Display the number of regions in each overlap group
    # Groups are named with binary notation (e.g., "111" = all three sets overlap)
    print(sapply(overlapGroups, length))

    # Export each overlap group as a separate BED file
    # This creates individual files for:
    # - group_111: regions in all three sets
    # - group_110: regions in sets 1 and 2 only
    # - group_101: regions in sets 1 and 3 only
    # - group_011: regions in sets 2 and 3 only
    # - group_100: regions in set 1 only
    # - group_010: regions in set 2 only
    # - group_001: regions in set 3 only
    exportOverlapsToBed(overlapGroups,
                        output_dir = output_dir,     # Same directory for both modes
                        output_prefix = cfg$prefix,  # Prefix for output filenames
                        with_date = FALSE)           # Don't append date to filenames
}

# ==============================================================================
# Output files generated in output/overlaps_bed/:
#
# "reduce" mode:
# - example_reduced_regions.bed: All distinct genomic regions (merged)
# - example_reduced_group_111.bed: Regions present in all three peak sets
# - example_reduced_group_110.bed: Regions present in peaksets 1 and 2 only
# - example_reduced_group_101.bed: Regions present in peaksets 1 and 3 only
# - example_reduced_group_011.bed: Regions present in peaksets 2 and 3 only
# - example_reduced_group_100.bed: Regions unique to peakset 1
# - example_reduced_group_010.bed: Regions unique to peakset 2
# - example_reduced_group_001.bed: Regions unique to peakset 3
#
# "disjoin" mode:
# - example_disjoint_regions.bed: All elementary genomic regions (disjoint)
# - example_disjoint_group_111.bed: Regions present in all three peak sets
# - example_disjoint_group_110.bed: Regions present in peaksets 1 and 2 only
# - example_disjoint_group_101.bed: Regions present in peaksets 1 and 3 only
# - example_disjoint_group_011.bed: Regions present in peaksets 2 and 3 only
# - example_disjoint_group_100.bed: Regions unique to peakset 1
# - example_disjoint_group_010.bed: Regions unique to peakset 2
# - example_disjoint_group_001.bed: Regions unique to peakset 3
# ==============================================================================
