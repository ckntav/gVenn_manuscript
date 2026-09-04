# ==============================================================================
# Script: Generate BED Files for Figure S1
# Purpose: Process example genomic peak sets (BED files), compute their overlaps,
#          and export the overlap groups as separate BED files for visualization
# Note:    Overlaps are computed with gVenn::computeOverlaps() in "disjoin" mode
#          (see scripts/create_figure1 for the "reduce" counterpart)
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
# Compute overlaps
# ==============================================================================
# Calculate all possible overlaps between the three peak sets
# This identifies which regions are:
# - Unique to one set
# - Shared by exactly two sets
# - Shared by all three sets
# mode = "disjoin" splits the peaks into the smallest non-overlapping intervals,
# so a single peak can be cut into several regions assigned to different groups
ov <- computeOverlaps(demo_peaks, mode = "disjoin")

# ==============================================================================
# Export disjoint regions
# ==============================================================================
# Extract the disjoint regions - the elementary genomic intervals obtained by
# cutting the peak sets at every boundary, so that any two regions are either
# identical or fully distinct
# Think of this as a "master set" of all elementary regions
demo_disjoint_regions <- ov$regions

# Report the total number of disjoint regions found
message("Total number of disjoint regions: ", length(demo_disjoint_regions))

# Export disjoint regions as a BED file for visualization
# rtracklayer::export() does not create missing directories, so make sure it exists
output_dir <- here("output", "overlaps_disjoint_bed")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

rtracklayer::export(demo_disjoint_regions,
                    format = "bed",
                    con = file.path(output_dir, "example_disjoint_regions.bed"))

# ==============================================================================
# Extract and Export Overlap Groups
# ==============================================================================
# Extract all overlap groups (e.g., regions in only set 1, only in sets 1&2, etc.)
# Each group represents a different combination of overlapping peak sets
overlapGroups <- extractOverlaps(ov)

# Display the number of regions in each overlap group
# Groups are named with binary notation (e.g., "111" = all three sets overlap)
sapply(overlapGroups, length)

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
                    output_dir = output_dir,     # Same directory as the disjoint regions
                    output_prefix = "example_disjoint",  # Prefix for output filenames
                    with_date = FALSE)           # Don't append date to filenames

# ==============================================================================
# Output files generated in output/overlaps_disjoint_bed/:
# - example_disjoint_regions.bed: All elementary genomic regions (disjoint)
# - example_disjoint_group_111.bed: Regions present in all three peak sets
# - example_disjoint_group_110.bed: Regions present in peaksets 1 and 2 only
# - example_disjoint_group_101.bed: Regions present in peaksets 1 and 3 only
# - example_disjoint_group_011.bed: Regions present in peaksets 2 and 3 only
# - example_disjoint_group_100.bed: Regions unique to peakset 1
# - example_disjoint_group_010.bed: Regions unique to peakset 2
# - example_disjoint_group_001.bed: Regions unique to peakset 3
# ==============================================================================
