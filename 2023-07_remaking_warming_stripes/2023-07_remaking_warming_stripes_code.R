# Remaking 'Warming Stripes' (originally by Ed Hawwkins), inspired by Dan Oehm

# Load libraries ---------------------------------------------------------------

library(readr)
library(dplyr)
library(stringr)
library(tidyr)
library(showtext)
library(ggplot2)
library(ggtext)

# Import 'live' data, source URL is derived from Tidy Tuesday GitHub -----------

raw_global_temps <- read_csv("https://data.giss.nasa.gov/gistemp/tabledata_v4/GLB.Ts+dSST.csv", skip = 1) |>
  mutate(across(-Year, as.numeric),
         Year = as.factor(Year))

# Transform data ---------------------------------------------------------------

processed_global_temps <- raw_global_temps |>
  select(Year,
         Jan, Feb, Mar, Apr, May, Jun,
         Jul, Aug, Sep, Oct, Nov, Dec) |>
  pivot_longer(-Year, names_to = "months", values_to = "temperature") |>
  rename_with(~ tolower(.x)) |>
  summarize(mean_temperature = mean(temperature, na.rm = TRUE), .by = year)

# Add Google font --------------------------------------------------------------

font_add_google("Open Sans")

showtext_auto()

# Make color palette -----------------------------------------------------------

color_palette <- c("2023" = "#67000d", # Warmest
                            "#a50f15",
                            "#cb181d",
                            "#ef3b2c",
                            "#fb6a4a",
                            "#fc9272",
                            "#fcbba1",
                            "#fee0d2", # Color palette source: https://en.wikipedia.org/wiki/Warming_stripes
                            "#c6dbef",
                            "#9ecae1",
                            "#6baed6",
                   "1880" = "#4292c6",
                            "#2171b5",
                            "#08519c",
                            "#08306b") # Coolest
             
# Visualize data and save visualization ----------------------------------------

processed_global_temps |>
  ggplot(aes(x = year,
             y = 1,
             fill = mean_temperature,
             width = 1.03)) +
  geom_col() +
  xlab("") +
  ylab("") +
  labs(title = paste0("Verandering jaarlijkse temperatuur wereldwijd van",
                      "<span style = 'color:",
                      color_palette["1880"],
                      ";'>",
                      " 1880 ",
                      "</span>",
                      "tot",
                      "<span style = 'color:",
                      color_palette["2023"],
                      ";'>",
                      " 2023",
                      "</span>")) +
  theme_minimal(base_size = 50,
                base_family = "Open Sans") +
  theme(legend.position = "none",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_text(vjust = 6.5,
                                   color = "#252525",
                                   face = "bold",
                                   size = 55),
        plot.title = element_markdown(face = "bold",
                                      color = "#252525",
                                      hjust = 0.5,
                                      margin = margin(t = 37)),
        plot.margin = grid::unit(c(-7.9, 8.5, -15, -5), "mm")) +
  scale_fill_gradientn(colours = rev(color_palette)) +
  scale_x_discrete(breaks = c(seq(1880, 2023, 30), 2023))

ggsave("2023-07_remaking_warming_stripes_viz.png",
       width = 11,
       height = 5,
       bg = "#F9F9F9")