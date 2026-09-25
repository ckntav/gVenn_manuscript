# ==============================================================================
# Script: Render Table 1 from the spreadsheet
# Input:  input/venn_tools/20260922_table1_venn_tools.xlsx
# Output: output/table1/Table1_venn_tools.{png,tiff}
# ==============================================================================

library(kableExtra)
library(here)

OUTPUT_DIR <- here("output", "table1")

# Logo shown beside this tool's name
HIGHLIGHT <- "gVenn"
LOGO_PATH <- here("docs", "img", "venn_logo.png")

# Column headings (group, heading), matched by regex on the sheet's column names
HEADERS <- list(
    "^tool$"       = c("",              "Tool"),
    "genomic"      = c("Input",         "Genomic regions"),
    "proportional" = c("Visualisation", "Proportional Venn"),
    "upset"        = c("Visualisation", "UpSet plot"),
    "released"     = c("",              "First release"),
    "env"          = c("",              "Environment"))

WIDTHS <- c("^tool$" = "8.5em", released = "12em", env = "11em",
            proportional = "11em", genomic = "10.5em")

# Text columns, not yes/no
DESCRIPTIVE <- "released|env|^tool$"

# ==============================================================================
# Read the sheet
# ==============================================================================
path <- here("input", "venn_tools", "20260922_table1_venn_tools.xlsx")
tbl <- as.data.frame(readxl::read_excel(path))
message("Reading ", basename(path), ": ", nrow(tbl), " tools, ", ncol(tbl), " columns")

# ==============================================================================
# What a cell means
# ==============================================================================
# "yes..." is a tick, anything else a cross; bracketed text is kept
TICK <- "✓"
CROSS <- "✗"
FILL <- c(yes = "#DFF0D8", no = "#F4F4F4", blank = "#FFFFFF")
INK <- c(yes = "#2F6B34", no = "#8A8A8A", blank = "#222222")

kind_of <- function(x) {
    v <- tolower(trimws(x))
    if (!nzchar(v)) "blank" else if (grepl("^yes\\b", v)) "yes" else "no"
}

symbolise <- function(x, kind) {
    if (kind == "blank") return("")
    qualifier <- if (grepl("\\(", x)) {
        trimws(gsub("^[^(]*\\(|\\)\\s*$", "", x))
    } else if (kind == "no" && !grepl("^no$", tolower(trimws(x)))) {
        trimws(x)
    } else ""

    mark <- if (kind == "no") CROSS else TICK
    if (!nzchar(qualifier)) return(mark)
    paste0(mark, "<span style='font-size:11px;white-space:nowrap'>&nbsp;(",
           qualifier, ")</span>")
}

styled <- tbl
for (j in seq_along(tbl)[-1]) {
    values <- tbl[[j]]
    if (grepl(DESCRIPTIVE, names(tbl)[j], ignore.case = TRUE)) {
        styled[[j]] <- cell_spec(values, color = "#222222", format = "html")
    } else {
        k <- vapply(values, kind_of, character(1))
        shown <- mapply(symbolise, values, k, USE.NAMES = FALSE)
        styled[[j]] <- cell_spec(shown, background = FILL[k], color = INK[k],
                                 bold = k != "no", escape = FALSE, format = "html")
    }
}

# Data URI, since the HTML is rendered from a temp directory
logo_img <- paste0("<img src='", knitr::image_uri(LOGO_PATH),
                   "' alt='' style='height:1.25em;vertical-align:-0.3em;",
                   "margin-right:6px'>")
names_col <- tbl[[1]]
names_col[tbl[[1]] == HIGHLIGHT] <- paste0(logo_img, HIGHLIGHT)
styled[[1]] <- cell_spec(names_col, bold = TRUE, color = "#222222",
                         escape = FALSE, format = "html")

# ==============================================================================
# Lay out
# ==============================================================================
lookup <- function(nm, table) {
    hit <- vapply(names(table), grepl, logical(1), x = nm, ignore.case = TRUE)
    if (!any(hit)) NULL else table[[which(hit)[1]]]
}

names(styled) <- vapply(names(tbl), function(nm) {
    h <- lookup(nm, HEADERS)
    if (is.null(h)) stop("no publication heading defined for the column \"", nm,
                         "\"", call. = FALSE)
    if (!nzchar(h[1])) return(h[2])
    paste0("<span style='font-weight:400;font-size:11px;color:#5A5A5A;",
           "letter-spacing:.02em'>", h[1], "</span><br>", h[2])
}, character(1))

tbl_html <- kbl(styled, escape = FALSE, align = c("l", rep("c", ncol(styled) - 1))) |>
    kable_styling(bootstrap_options = "condensed", full_width = FALSE,
                  font_size = 13, html_font = "Helvetica Neue, Helvetica, Arial") |>
    row_spec(0, bold = TRUE, background = "#FFFFFF", color = "#222222",
             extra_css = "border-bottom: 1.5px solid #222; vertical-align: bottom;") |>
    column_spec(1, bold = TRUE, width = WIDTHS[["^tool$"]])

for (j in seq_along(styled)[-1]) {
    w <- lookup(names(tbl)[j], as.list(WIDTHS))
    tbl_html <- column_spec(tbl_html, j, width = if (is.null(w)) "8em" else w)
}

# ==============================================================================
# Write
# ==============================================================================
dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)
png_path <- file.path(OUTPUT_DIR, "table1_venn_tools.png")
tiff_path <- file.path(OUTPUT_DIR, "table1_venn_tools.tiff")

html <- paste0(
    "<style>",
    "body { margin: 0; background: #FFFFFF; }",
    "table { margin: 0; }",
    "td, th { padding: 7px 9px !important; }",
    "</style>",
    as.character(tbl_html))

save_kable(structure(html, format = "html", class = "knitr_kable"),
           file = png_path, zoom = 4, density = 300)

# save_kable crops to content, so add the margin back
MARGIN_PX <- 80
img <- magick::image_border(magick::image_read(png_path), "#FFFFFF",
                            paste0(MARGIN_PX, "x", MARGIN_PX))
magick::image_write(img, png_path, format = "png", density = "300x300")
magick::image_write(img, tiff_path, format = "tiff", compression = "LZW",
                    density = "300x300")

info <- magick::image_info(img)
message("Written ", png_path)
message("Written ", tiff_path, "  (", info$width, " x ", info$height,
        " px, LZW, 300 dpi)")