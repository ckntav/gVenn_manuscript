library(hexSticker) # devtools::install_github("GuangchuangYu/hexSticker")
library(showtext)
library(here)

font_add("Century Gothic", regular = here("input", "fonts", "centurygothic.ttf"))
showtext_auto()  # enable showtext

imgurl <- here("output", "hex_sticker_logo", "venn_logo.png")

# png
sticker(imgurl, package = "gVenn",
        p_x = 1, p_y = 0.45, # position for package name
        s_x = 1, s_y = 1.2, # position for subplot
        s_width = 0.55, # size for subplot
        p_family = "Century Gothic", p_size = 36, # font for package name
        h_fill = "white",
        h_size = 1.2, h_color = "black",
        dpi = 600, , p_color = "black",
        filename = here("output", "hex_sticker_logo", "gVenn_hex_sticker.png"))

# png with url
sticker(imgurl, package = "gVenn",
        p_x = 1, p_y = 0.45, # position for package name
        s_x = 1, s_y = 1.2, # position for subplot
        s_width = 0.55, # size for subplot
        p_family = "Century Gothic", p_size = 36, # font for package name
        h_fill = "white",
        h_size = 1.2, h_color = "black",
        dpi = 600, , p_color = "black",
        url = "github.com/ckntav/gVenn",
        u_color = "#303030", u_size = 5, u_family = "Century Gothic",
        filename = here("output", "hex_sticker_logo", "gVenn_hex_sticker_with_url.png"))
