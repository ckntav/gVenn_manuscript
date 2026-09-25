# ==============================================================================
# Script: Build Figure 1B and 1C
# Purpose: Venn diagrams (1B) and UpSet plots (1C), reduce | disjoin
# ==============================================================================

library(gVenn)
library(GenomicRanges)
library(here)

# ==============================================================================
# Settings
# ==============================================================================
# eulerr's fit starts from random values
SEED <- 1111
set.seed(SEED)

# Single thread makes eulerr's diagError reproducible across runs
Sys.setenv(EULERR_NUM_THREADS = 1)

panel_width_mm  <- 178
venn_height_mm  <- 55
upset_height_mm <- 60    # plotUpSet() reserves 2 cm for the top barplot

mm2in <- function(mm) mm / 25.4

output_dir <- here("output", "figure1")

# ==============================================================================
# Import data and compute overlaps
# ==============================================================================
peakset1 <- rtracklayer::import(here("input", "example_bed", "peakset1.bed"))
peakset2 <- rtracklayer::import(here("input", "example_bed", "peakset2.bed"))
peakset3 <- rtracklayer::import(here("input", "example_bed", "peakset3.bed"))

demo_peaks <- GRangesList("peakset1" = peakset1,
                          "peakset2" = peakset2,
                          "peakset3" = peakset3)

sapply(demo_peaks, length)

overlaps <- list(
    "reduce"  = computeOverlaps(demo_peaks, mode = "reduce"),
    "disjoin" = computeOverlaps(demo_peaks, mode = "disjoin")
)

mode_title <- function(mode) paste0('mode = "', mode, '"')

# ==============================================================================
# Colors
# ==============================================================================
# make_comb_mat() order (111, 110, 101, 011, 100, 010, 001), same as panel 1A
group_colors <- c("#D87093",
                  "#CD3301",
                  "#9370DB",
                  "#008B8B",
                  "#2B70AB",
                  "#FFB027",
                  "#3EA742")

# ==============================================================================
# Figure 1B: Venn diagrams
# ==============================================================================
# labels = FALSE: outer set labels shrink the ellipses at this height
venn_plots <- lapply(names(overlaps), function(mode) {
    plotVenn(overlaps[[mode]],
             labels = FALSE,
             legend = TRUE,
             main = mode_title(mode))
})
names(venn_plots) <- names(overlaps)

# arrangeGrob() would give a gtable that saveViz() saves as an empty page
fig1B <- cowplot::plot_grid(plotlist = unname(venn_plots), nrow = 1)

saveViz(fig1B,
        output_dir = output_dir,
        output_file = "fig1B_venn",
        with_date = FALSE,
        width = mm2in(panel_width_mm),
        height = mm2in(venn_height_mm))

message("Panel 1B: ", panel_width_mm, " x ", venn_height_mm, " mm")

# Goodness of fit per region and mode, only reproducible for a given seed and eulerr version
venn_diagnostics <- do.call(rbind, lapply(names(venn_plots), function(mode) {
    fit <- attr(venn_plots[[mode]], "fit_diagnostics")

    data.frame(mode                 = mode,
               region               = names(fit$regionError),
               region_error         = as.numeric(fit$regionError),
               undrawn              = names(fit$regionError) %in%
                                          fit$undrawnRegions,
               stress               = fit$stress,
               diag_error           = fit$diagError,
               diag_error_threshold = 1e-6,
               seed                 = SEED,
               eulerr_version       = as.character(packageVersion("eulerr")),
               stringsAsFactors     = FALSE)
}))

diagnostics_file <- file.path(output_dir, "fig1B_venn_fit_diagnostics.csv")
write.csv(venn_diagnostics, diagnostics_file, row.names = FALSE)

message(" > Venn fit diagnostics saved in ", diagnostics_file)

# ==============================================================================
# Figure 1C: UpSet plots
# ==============================================================================
# plotUpSet() returns a Heatmap, grabbed into a grob for layout
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
