# ==============================================================================
# Script: Generate BED Files for Figure 1
# Purpose: Process example genomic peak sets (BED files), compute their overlaps,
#          and export the overlap groups as separate BED files for visualization
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
ov <- computeOverlaps(demo_peaks)

# ==============================================================================
# Export reduced regions
# ==============================================================================
# Extract the "reduced regions" - these are the minimal non-overlapping
# genomic intervals that represent all unique overlap combinations
# Think of this as a "master set" of all distinct regions
demo_reduced_regions <- ov$reduced_regions

# Report the total number of reduced regions found
message("Total number of reduced regions:", length(demo_reduced_regions))

# Export reduced regions as a BED file for visualization
# This will show all regions that have any peaks, merged into non-overlapping intervals
rtracklayer::export(demo_reduced_regions, 
                    format = "bed", 
                    con = here("output", "overlaps_bed", "example_reduced_regions.bed"))

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
                    output_dir = here("output", "overlaps_bed"),
                    output_prefix = "example",  # Prefix for output filenames
                    with_date = FALSE)          # Don't append date to filenames

# ==============================================================================
# Output files generated:
# - example_reduced_regions.bed: All distinct genomic regions (merged)
# - example_group_111.bed: Regions present in all three peak sets
# - example_group_110.bed: Regions present in peaksets 1 and 2 only
# - example_group_101.bed: Regions present in peaksets 1 and 3 only
# - example_group_011.bed: Regions present in peaksets 2 and 3 only
# - example_group_100.bed: Regions unique to peakset 1
# - example_group_010.bed: Regions unique to peakset 2
# - example_group_001.bed: Regions unique to peakset 3
# ==============================================================================