#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "SCRIPT_DIR: $SCRIPT_DIR"

quarto render "$SCRIPT_DIR/supplementary_data_S1_chipseq_workflow.qmd"
quarto render "$SCRIPT_DIR/supplementary_data_S2_gene_set_workflow.qmd"
