# gVenn (manuscript repository)

![Maintainer](https://img.shields.io/badge/maintainer-ckntav-blue)
[![Bioconductor](https://img.shields.io/badge/Bioconductor-gVenn-1a81c2)](https://bioconductor.org/packages/gVenn)
[![Website](https://img.shields.io/badge/website-online-brightgreen)](https://ckntav.github.io/gVenn_manuscript/)

**Proportional Venn diagrams for genomic regions and gene set overlaps**

<p align="center">
<img src="output/hex_sticker_logo/gVenn_hex_sticker.png" width="175"/>
</p>

## 🌐 Website

View the [**gVenn manuscript website**](https://ckntav.github.io/gVenn_manuscript/)

## 📄 About this repository

This repository holds the code, inputs and outputs behind the gVenn manuscript: Figure 1, Table 1 and Supplementary Data S1 and S2.

## 🗂️ Repository layout

| Item | Script | Inputs | Outputs |
|---|---|---|---|
| Figure 1 | `scripts/create_figure1/01-03_*.R` | `input/example_bed/peakset{1,2,3}.bed` | `output/overlaps_bed/`, `output/figure1/` |
| Table 1 | `scripts/create_table1/build_table1.R` | `input/venn_tools/20260922_table1_venn_tools.xlsx` | `output/table1/` |
| Supplementary Data S1, S2 | `scripts/supplementary_data/*.qmd` | | `docs/supp_data_S{1,2}.html` |
| Hex sticker | `scripts/generate_hex_sticker_logo/01-02_*.R` | `input/fonts/centurygothic.ttf` | `output/hex_sticker_logo/` |
| Download stats | `scripts/update_dl_stats/update_dl_stats.R` | | `docs/index.html` |
| Graphical abstract | made in Illustrator | | `output/graphical_abstract/` |

The PDFs in `output/figure1/` are the raw panels. The final figure is assembled and annotated in Illustrator.

The download stats on the website are refreshed daily by the GitHub Action in `.github/workflows/update-stats.yml`.

## 🔁 Reproducing

Requirements: R with gVenn, GenomicRanges, rtracklayer, plotgardener, tidyverse, kableExtra, knitr, org.Hs.eg.db, hexSticker, showtext and here. The supplementary notebooks also need [Quarto](https://quarto.org).

Run the scripts from the repository root, since they resolve paths with `here()`:

```bash
# Figure 1 (02 and 03 read the BED files written by 01)
Rscript scripts/create_figure1/01_generate_overlaps_bed.R
Rscript scripts/create_figure1/02_build_figure1A.R
Rscript scripts/create_figure1/03_build_figure1BC.R

# Table 1
Rscript scripts/create_table1/build_table1.R

# Supplementary Data S1 and S2, rendered into docs/
bash scripts/supplementary_data/render_supplementary.sh
```

`03_build_figure1BC.R` sets a fixed seed because the eulerr fit starts from random values.

## 📚 Citation

<!-- TODO: add the manuscript reference or preprint DOI -->

To cite the package, run `citation("gVenn")` in R.

---

**R package:** [github.com/ckntav/gVenn](https://github.com/ckntav/gVenn)  
**Bioconductor:** [bioconductor.org/packages/gVenn](https://bioconductor.org/packages/gVenn)
