library(gVenn) # pak::pak("ckntav/gVenn")
library(org.Hs.eg.db)
library(here)

packageVersion("gVenn") # should be >= 0.99.6 to be able to get a transparent background

## ------------------------------------------------------------------
## 1) Get a small universe of real human gene symbols
## ------------------------------------------------------------------
all_genes <- unique(keys(org.Hs.eg.db, keytype = "SYMBOL"))
universe  <- head(all_genes, 250)   # plenty for our target below

## ------------------------------------------------------------------
## 2) Choose target sizes and overlaps (edit these if you like)
## ------------------------------------------------------------------
sizes <- list(
    A_only  = 7,
    B_only  = 7,
    C_only  = 7,
    AB_only = 3,
    AC_only = 3,
    BC_only = 3,
    ABC     = 4
)

## ------------------------------------------------------------------
## 3) Helper to sample disjoint partitions from the universe
## ------------------------------------------------------------------
set.seed(1111)

take <- function(pool, n) {
    if (n == 0) return(list(pick = character(), pool = pool))
    stopifnot(length(pool) >= n)
    pick <- sample(pool, n, replace = FALSE)
    list(pick = pick, pool = setdiff(pool, pick))
}

## Draw disjoint blocks in any order
tmp <- take(universe, sizes$ABC);      ABC     <- tmp$pick; pool <- tmp$pool
tmp <- take(pool,     sizes$AB_only);  AB_only <- tmp$pick; pool <- tmp$pool
tmp <- take(pool,     sizes$AC_only);  AC_only <- tmp$pick; pool <- tmp$pool
tmp <- take(pool,     sizes$BC_only);  BC_only <- tmp$pick; pool <- tmp$pool
tmp <- take(pool,     sizes$A_only);   A_only  <- tmp$pick; pool <- tmp$pool
tmp <- take(pool,     sizes$B_only);   B_only  <- tmp$pick; pool <- tmp$pool
tmp <- take(pool,     sizes$C_only);   C_only  <- tmp$pick; pool <- tmp$pool

## ------------------------------------------------------------------
## 4) Assemble sets A, B, C from the partitions
## ------------------------------------------------------------------
random_genes_A <- c(A_only, AB_only, AC_only, ABC)
random_genes_B <- c(B_only, AB_only, BC_only, ABC)
random_genes_C <- c(C_only, AC_only, BC_only, ABC)

gene_list <- list(
    random_genes_A = random_genes_A,
    random_genes_B = random_genes_B,
    random_genes_C = random_genes_C
)

ov <- computeOverlaps(gene_list)

venn <- plotVenn(ov, quantities = FALSE, legend = FALSE,
                 fill = c("#2B70AB", "#FFB027", "#3EA742", "#CD3301", "#9370DB", "#008B8B", "#F08080"))

venn

saveViz(venn,
        format = "png",
        output_dir = here("output", "hex_sticker_logo"),
        output_file = "venn_logo",
        with_date = FALSE)