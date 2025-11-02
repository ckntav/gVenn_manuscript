# ==============================================================================
# Script: Generate Venn diagram logo for hex dticker
# Purpose: Create a 3-way Venn diagram with controlled overlaps using real
#          human gene symbols for a package logo
# ==============================================================================

library(gVenn)        # For creating Venn diagrams
library(org.Hs.eg.db) # Human genome annotation database for gene symbols
library(here)         # For robust file path management

# Check package version - need >= 1.1.1 for transparent background support
packageVersion("gVenn")

## ------------------------------------------------------------------
## 1) Get a small universe of real human gene symbols
## ------------------------------------------------------------------
# Extract all unique human gene symbols from the annotation database
all_genes <- unique(keys(org.Hs.eg.db, keytype = "SYMBOL"))

# Create a manageable subset (250 genes is sufficient for our purposes)
# Using real gene names rather than synthetic data for authenticity
universe  <- head(all_genes, 250)


## ------------------------------------------------------------------
## 1) Get a small universe of real human gene symbols
## ------------------------------------------------------------------
all_genes <- unique(keys(org.Hs.eg.db, keytype = "SYMBOL"))
universe  <- head(all_genes, 250)   # plenty for our target below

## ------------------------------------------------------------------
## 2) Choose target sizes and overlaps
## ------------------------------------------------------------------
# Define the number of genes in each partition of the 3-way Venn diagram:
# - A_only, B_only, C_only: genes unique to each set
# - AB_only, AC_only, BC_only: genes shared by exactly two sets
# - ABC: genes shared by all three sets
sizes <- list(
    A_only  = 7,  # Genes only in set A
    B_only  = 7,  # Genes only in set B
    C_only  = 7,  # Genes only in set C
    AB_only = 3,  # Genes in both A and B, but not C
    AC_only = 3,  # Genes in both A and C, but not B
    BC_only = 3,  # Genes in both B and C, but not A
    ABC     = 4   # Genes in all three sets (A, B, and C)
)

## ------------------------------------------------------------------
## 3) Helper to sample disjoint partitions from the universe
## ------------------------------------------------------------------
# Set seed for reproducibility
set.seed(1111)

# Helper function to randomly sample genes without replacement
# Returns both the selected genes and the remaining pool
take <- function(pool, n) {
    # Handle case where no genes are needed
    if (n == 0) return(list(pick = character(), pool = pool))
    
    # Ensure we have enough genes in the pool
    stopifnot(length(pool) >= n)
    
    # Randomly sample n genes from the pool
    pick <- sample(pool, n, replace = FALSE)
    
    # Return sampled genes and update pool (removing selected genes)
    list(pick = pick, pool = setdiff(pool, pick))
}

# Sample genes for each partition, ensuring no overlap between partitions
# Each call updates the pool to exclude already-selected genes

# Start with the central overlap (all three sets)
tmp <- take(universe, sizes$ABC);      ABC     <- tmp$pick; pool <- tmp$pool

# Then sample pairwise overlaps
tmp <- take(pool,     sizes$AB_only);  AB_only <- tmp$pick; pool <- tmp$pool
tmp <- take(pool,     sizes$AC_only);  AC_only <- tmp$pick; pool <- tmp$pool
tmp <- take(pool,     sizes$BC_only);  BC_only <- tmp$pick; pool <- tmp$pool

# Finally sample unique genes for each set
tmp <- take(pool,     sizes$A_only);   A_only  <- tmp$pick; pool <- tmp$pool
tmp <- take(pool,     sizes$B_only);   B_only  <- tmp$pick; pool <- tmp$pool
tmp <- take(pool,     sizes$C_only);   C_only  <- tmp$pick; pool <- tmp$pool

## ------------------------------------------------------------------
## 4) Assemble sets A, B, C from the partitions
## ------------------------------------------------------------------
# Construct each set by combining its relevant partitions:
# Set A contains: genes unique to A + genes shared with B + genes shared with C + genes in all three
random_genes_A <- c(A_only, AB_only, AC_only, ABC)

# Set B contains: genes unique to B + genes shared with A + genes shared with C + genes in all three
random_genes_B <- c(B_only, AB_only, BC_only, ABC)

# Set C contains: genes unique to C + genes shared with A + genes shared with B + genes in all three
random_genes_C <- c(C_only, AC_only, BC_only, ABC)

# Create named list of gene sets for Venn diagram
gene_list <- list(
    random_genes_A = random_genes_A,
    random_genes_B = random_genes_B,
    random_genes_C = random_genes_C
)

# ------------------------------------------------------------------
## 5) Generate and save the Venn diagram
## ------------------------------------------------------------------
# Compute overlaps between the three gene sets
ov <- computeOverlaps(gene_list)

# Create Venn diagram visualization
# - quantities = FALSE: don't show counts on the diagram
# - legend = FALSE: don't show a legend
# - fill: custom color palette for the diagram regions
venn <- plotVenn(ov, 
                 quantities = FALSE, 
                 legend = FALSE,
                 fill = c("#2B70AB", "#FFB027", "#3EA742", "#CD3301", "#9370DB", "#008B8B", "#F08080"))

# Display the Venn diagram
venn

# Save the visualization as PNG
# - format: output file format
# - output_dir: directory to save the file
# - output_file: name of the output file (without extension)
# - with_date: don't append date to filename for consistency
saveViz(venn,
        format = "png",
        output_dir = here("output", "hex_sticker_logo"),
        output_file = "venn_logo",
        with_date = FALSE)