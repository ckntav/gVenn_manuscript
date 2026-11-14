# ==============================================================================
# Script: Render Table 1 from the spreadsheet as an editable Word table
# Input:  input/venn_tools/20260927_table1_venn_tools.xlsx
# Output: output/table1/table1_venn_tools.docx
# ==============================================================================

library(flextable)
library(officer)
library(here)

OUTPUT_DIR <- here("output", "table1")

# Logo shown beside this tool's name
HIGHLIGHT <- "gVenn"
LOGO_PATH <- here("docs", "img", "venn_logo.png")

# Column headings (group, heading), matched by regex on the sheet's column names
HEADERS <- list(
    "^tool$"       = c("",              "Tool"),
    "genomic"      = c("Input",         "Genomic regions"),
    "proportional" = c("Visualization", "Proportional Venn"),
    "upset"        = c("Visualization", "UpSet plot"),
    "released"     = c("",              "First release"),
    "env"          = c("",              "Environment"))

# Column widths in inches
WIDTHS <- c("^tool$" = 1.2, released = 1.55, env = 1.85,
            proportional = 1.75, genomic = 1.45, upset = 1)

# Text columns, not yes/no
DESCRIPTIVE <- "released|env|^tool$"

FONT <- "Arial"
SIZE <- 10
SMALL <- 8.5

# ==============================================================================
# Read the sheet
# ==============================================================================
path <- here("input", "venn_tools", "20260927_table1_venn_tools.xlsx")
tbl <- as.data.frame(readxl::read_excel(path))
message("Reading ", basename(path), ": ", nrow(tbl), " tools, ", ncol(tbl), " columns")

# ==============================================================================
# What a cell means
# ==============================================================================
# "yes..." is a tick, anything else a cross; bracketed text is kept
TICK <- "✓"
CROSS <- "✗"
PAD <- " "
FILL <- c(yes = "#DFF0D8", no = "#F4F4F4", blank = "#FFFFFF")
INK <- c(yes = "#2F6B34", no = "#8A8A8A", blank = "#222222")

kind_of <- function(x) {
    v <- tolower(trimws(x))
    if (is.na(v) || !nzchar(v)) "blank" else if (grepl("^yes\\b", v)) "yes" else "no"
}

qualifier_of <- function(x, kind) {
    if (kind == "blank") return("")
    if (grepl("\\(", x)) return(trimws(gsub("^[^(]*\\(|\\)\\s*$", "", x)))
    if (kind == "no" && !grepl("^no$", tolower(trimws(x)))) trimws(x) else ""
}

lookup <- function(nm, table) {
    hit <- vapply(names(table), grepl, logical(1), x = nm, ignore.case = TRUE)
    if (!any(hit)) NULL else table[[which(hit)[1]]]
}

heads <- lapply(names(tbl), function(nm) {
    h <- lookup(nm, HEADERS)
    if (is.null(h)) stop("no publication heading defined for the column \"", nm,
                         "\"", call. = FALSE)
    h
})
groups <- vapply(heads, `[`, character(1), 1)
labels <- vapply(heads, `[`, character(1), 2)

keys <- paste0("c", seq_along(tbl))
is_text <- grepl(DESCRIPTIVE, names(tbl), ignore.case = TRUE)

shown <- tbl
names(shown) <- keys
kinds <- matrix("blank", nrow(tbl), ncol(tbl))
for (j in seq_along(tbl)) {
    if (is_text[j]) {
        shown[[j]] <- gsub("\r\n|\r", "\n", tbl[[j]])
    } else {
        kinds[, j] <- vapply(tbl[[j]], kind_of, character(1))
        # Non-breaking spaces widen the highlight by one space each side
        shown[[j]] <- ifelse(kinds[, j] == "no", paste0(PAD, CROSS, PAD),
                             ifelse(kinds[, j] == "yes", paste0(PAD, TICK, PAD), ""))
    }
}

# ==============================================================================
# Lay out
# ==============================================================================
ft <- flextable(shown, col_keys = keys) |>
    set_header_labels(values = setNames(as.list(labels), keys)) |>
    border_remove() |>
    font(fontname = FONT, part = "all") |>
    fontsize(size = SIZE, part = "all") |>
    color(color = "#222222", part = "all") |>
    padding(padding.top = 4, padding.bottom = 4, padding.left = 5,
            padding.right = 5, part = "all")

# Header
ft <- bold(ft, part = "header")
# Group label in small grey above the heading, in the same cell
for (j in which(nzchar(groups))) {
    ft <- compose(ft, i = 1, j = keys[j], part = "header", value = as_paragraph(
        as_chunk(groups[j], props = fp_text(color = "#5A5A5A", font.family = FONT,
                                            font.size = SMALL)),
        "\n",
        as_chunk(labels[j], props = fp_text(color = "#222222", bold = TRUE,
                                            font.family = FONT, font.size = SIZE))))
}
ft <- ft |>
    align(align = "center", part = "all") |>
    align(j = 1, align = "left", part = "all") |>
    valign(valign = "bottom", part = "header") |>
    valign(valign = "center", part = "body") |>
    hline_bottom(border = fp_border(color = "#222222", width = 1.5),
                 part = "header")

# Body
ft <- bold(ft, j = 1, part = "body")
# Grey rule between tools
ft <- hline(ft, i = seq_len(nrow(tbl) - 1), part = "body",
            border = fp_border(color = "#BFBFBF", width = 0.5))
for (j in which(!is_text)) {
    for (k in c("yes", "no")) {
        i <- which(kinds[, j] == k)
        if (!length(i)) next
        ft <- ft |>
            highlight(i = i, j = keys[j], color = FILL[[k]]) |>
            color(i = i, j = keys[j], color = INK[[k]]) |>
            bold(i = i, j = keys[j], bold = k != "no")
    }
    # Mark plus a smaller bracketed qualifier
    for (i in seq_len(nrow(tbl))) {
        k <- kinds[i, j]
        q <- qualifier_of(tbl[[j]][i], k)
        if (!nzchar(q)) next
        props <- fp_text(color = INK[[k]], bold = k != "no", font.family = FONT,
                         font.size = SIZE, shading.color = FILL[[k]])
        ft <- compose(ft, i = i, j = keys[j], value = as_paragraph(
            as_chunk(sub(paste0(PAD, "$"), "", shown[[j]][i]), props = props),
            as_chunk(paste0(" (", q, ")", PAD), props = update(props, font.size = SMALL))))
    }
}

hl <- which(tbl[[1]] == HIGHLIGHT)
if (length(hl)) {
    ft <- compose(ft, i = hl, j = keys[1], value = as_paragraph(
        as_image(LOGO_PATH, width = 0.17, height = 0.17),
        as_chunk(paste0(" ", HIGHLIGHT),
                 props = fp_text(bold = TRUE, color = "#222222",
                                 font.family = FONT, font.size = SIZE))))
}

for (j in seq_along(keys)) {
    w <- lookup(names(tbl)[j], as.list(WIDTHS))
    ft <- width(ft, j = keys[j], width = if (is.null(w)) 1.2 else w)
}

# ==============================================================================
# Write
# ==============================================================================
dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)
docx_path <- file.path(OUTPUT_DIR, "table1_venn_tools.docx")
save_as_docx(ft, path = docx_path,
             pr_section = prop_section(page_size = page_size(orient = "landscape")))
message("Written ", docx_path)
