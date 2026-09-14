# ==============================================================================
# Script: Build Figure 1B and 1C - Venn diagrams and UpSet plots
# Purpose: Create two complementary summaries of the peak set overlaps, each
#          showing BOTH partitioning modes of gVenn::computeOverlaps():
#          - Figure 1B: two Venn diagrams (reduce | disjoin)
#          - Figure 1C: two UpSet plots   (reduce | disjoin)
# Note:    The counts differ between the two modes because "disjoin" cuts the
#          peaks at every boundary, so a single peak can contribute to several
#          overlap groups, while "reduce" merges them and assigns each region to
#          exactly one group. Panel 1A shows the same contrast on the tracks
# ==============================================================================

# Load required packages
library(gVenn)         # For computing and visualizing set overlaps
library(GenomicRanges) # For working with genomic intervals
library(here)          # For robust file path construction

# ==============================================================================
# Panel dimensions
# ==============================================================================
# Journal limits: 84 mm for a single column, 178 mm for a double column, and
# 230 mm of height. Figure 1 is assembled as panels A / B / C stacked
# vertically; panels B and C each hold two plots side by side and take the full
# double-column width, while panel A stays narrower and is centred
panel_width_mm  <- 178   # Double-column width, shared by both panels
venn_height_mm  <- 55    # Panel 1B
upset_height_mm <- 60    # Panel 1C, taller because plotUpSet() reserves 2 cm
                         # for the intersection barplot on top

mm2in <- function(mm) mm / 25.4

output_dir <- here("output", "figure1")

# ==============================================================================
# Import example data
# ==============================================================================
# The same three demonstration BED files used in scripts 01 and 02
peakset1 <- rtracklayer::import(here("input", "example_bed", "peakset1.bed"))
peakset2 <- rtracklayer::import(here("input", "example_bed", "peakset2.bed"))
peakset3 <- rtracklayer::import(here("input", "example_bed", "peakset3.bed"))

# ==============================================================================
# Organize data
# ==============================================================================
# Combine into a named GRangesList for analysis
demo_peaks <- GRangesList("peakset1" = peakset1,
                          "peakset2" = peakset2,
                          "peakset3" = peakset3)

# Display the number of peaks in each set
sapply(demo_peaks, length)

# ==============================================================================
# Compute overlaps in both modes
# ==============================================================================
# mode = "reduce" (the default) merges overlapping regions within each set
# before intersecting them, so each region belongs to a single combination
# mode = "disjoin" splits the peaks into the smallest non-overlapping intervals
overlaps <- list(
    "reduce"  = computeOverlaps(demo_peaks, mode = "reduce"),
    "disjoin" = computeOverlaps(demo_peaks, mode = "disjoin")
)

# Title placed above each of the two sub-plots, matching the wording of the
# vertical mode brackets in panel 1A
mode_title <- function(mode) paste0('mode = "', mode, '"')

# ==============================================================================
# Shared color palette
# ==============================================================================
# Colors of the seven overlap combinations, in the order ComplexHeatmap returns
# them from make_comb_mat(): 111, 110, 101, 011, 100, 010, 001
# That order is identical for both modes, so a single vector serves both UpSet
# plots. It is also the palette used for the group rows of panel 1A, and the
# default fills of plotVenn() follow the same scheme
group_colors <- c("#D87093",  # 111: present in all three sets (pink)
                  "#CD3301",  # 110: sets 1 and 2 (red)
                  "#9370DB",  # 101: sets 1 and 3 (purple)
                  "#008B8B",  # 011: sets 2 and 3 (teal)
                  "#2B70AB",  # 100: unique to set 1 (blue)
                  "#FFB027",  # 010: unique to set 2 (orange)
                  "#3EA742")  # 001: unique to set 3 (green)

# ==============================================================================
# Figure 1B: Venn diagrams
# ==============================================================================
# Venn diagrams are intuitive but become cluttered with >3 sets
# Each diagram carries its own legend, drawn by plotVenn() itself
# The set names are deliberately NOT written on the ellipses (labels = FALSE):
# eulerr then reserves room for the leader lines of the outer labels, which
# shrinks the ellipses to almost nothing at this panel height
venn_grobs <- lapply(names(overlaps), function(mode) {
    plotVenn(overlaps[[mode]],
             labels = FALSE,         # No set names on the ellipses
             legend = TRUE,          # plotVenn() draws its own legend
             main = mode_title(mode))
})

# plotVenn() returns an eulergram, which is already a grid grob, so the two
# diagrams can be laid out side by side as a single object
# cowplot::plot_grid() is used rather than gridExtra::arrangeGrob(): the latter
# returns a gtable whose print() method only prints a textual summary, so
# saveViz() would save an empty page
fig1B <- cowplot::plot_grid(plotlist = venn_grobs, nrow = 1)

saveViz(fig1B,
        output_dir = output_dir,
        output_file = "fig1B_venn",
        with_date = FALSE,
        width = mm2in(panel_width_mm),
        height = mm2in(venn_height_mm))

message("Panel 1B: ", panel_width_mm, " x ", venn_height_mm, " mm")

# ==============================================================================
# Figure 1C: UpSet plots
# ==============================================================================
# UpSet plots are a more scalable alternative to Venn diagrams: they use a
# matrix layout that shows all combinations explicitly and scales to many sets
#
# plotUpSet() returns a ComplexHeatmap object rather than a grob, so it cannot
# be arranged directly. grid.grabExpr() captures the drawing into a gTree, which
# can then be combined the same way as the Venn diagrams
upset_grobs <- lapply(names(overlaps), function(mode) {
    upset <- plotUpSet(overlaps[[mode]], comb_col = group_colors)

    grid::grid.grabExpr(
        ComplexHeatmap::draw(upset, column_title = mode_title(mode))
    )
})

fig1C <- cowplot::plot_grid(plotlist = upset_grobs, nrow = 1)

saveViz(fig1C,
        output_dir = output_dir,
        output_file = "fig1C_upset",
        with_date = FALSE,
        width = mm2in(panel_width_mm),
        height = mm2in(upset_height_mm))

message("Panel 1C: ", panel_width_mm, " x ", upset_height_mm, " mm")

# ==============================================================================
# Output files generated in output/figure1/:
# - fig1B_venn.pdf:  two Venn diagrams, "reduce" | "disjoin"
# - fig1C_upset.pdf: two UpSet plots,   "reduce" | "disjoin"
#
# Visualization comparison:
#
# Venn Diagram (Figure 1B):
# - Pros: Intuitive, shows spatial relationships, familiar to most readers
# - Cons: Becomes cluttered with >3 sets, area sizes not always proportional
# - Best for: 2-3 sets, general audience
#
# UpSet Plot (Figure 1C):
# - Pros: Scales to many sets, exact counts displayed, shows all combinations
# - Cons: Less intuitive initially, requires explanation for some readers
# - Best for: 4+ sets, detailed quantitative comparisons
#
# Both use the color scheme of panel 1A to keep the figure consistent
# ==============================================================================
