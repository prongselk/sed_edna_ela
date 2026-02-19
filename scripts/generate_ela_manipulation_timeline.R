##this script makes a graph out of the sql database of lake manipulations

##setup
library(RSQLite)
library(tidyverse)
library(viridis)


outputdir <- ("./data/plots/")

conn <- dbConnect(RSQLite::SQLite(), "./data/sql/records.db")
query <- "
SELECT 
    M.manipulation_id,
    M.lake_id,
    M.start_year,
    M.end_year,
    M.manipulation_name
FROM 
    Manipulations M
JOIN 
    Lakes L
ON 
    M.lake_id = L.lake_id
"
df <- dbGetQuery(conn, query)
dbDisconnect(conn)


#changing columns to factor data type
df$start_year <- as.numeric(df$start_year)
df$end_year <- as.numeric(df$end_year)
df$manipulation_name <- as.factor(df$manipulation_name)

#adding a column to indicate for which events I want point on the graph
df$show_point_tr <- ifelse(df$manipulation_name %in% c("Forest fire"), TRUE, FALSE)

df$show_point_li <- ifelse(df$manipulation_name %in% c("Dividing curtain installation",
                                                       "Dividing curtain removal"), TRUE, FALSE)

#column for lake id without extra characters
df <- df %>%
  mutate(lake_name = str_remove(lake_id, "ELAoL"))

#colours for the graph
manipulation_colours <- c(
  "Drawdown" = "lightblue",
  "Fertilisation" = "darkgreen",
  "Forest fire" = "darkorange",
  "Pike introduction" = "pink",
  "Pike removal" = "maroon",
  "Dividing curtain installation" = "royalblue",
  "Dividing curtain removal" = "purple4",
  "Control" = "#E3EFD8"
)

#remove mixing of basins as per Mike's suggestion

df<-df %>% 
  filter(manipulation_name!="Mixing of basins")


#plot 
timeline<- ggplot(df, aes(x = start_year, y = lake_name, color = manipulation_name)) +
  geom_segment(aes(xend = end_year, yend = lake_name), linewidth = 15, alpha=0.5) +
  geom_point(data = subset(df, show_point_tr), aes(x = start_year), size = 5, shape = 17) +
  geom_point(data = subset(df, show_point_li), aes(x = start_year), size = 22, shape = "|") +
  labs(title = "Manipulations and observations",
       x = "Year",
       y = "Lake ID",
       color = "Manipulation") +
  theme_bw() +
  scale_color_manual(values=manipulation_colours) +
  scale_x_continuous(breaks = seq(1968, 2010, by = 2)) +
  theme(legend.position = "bottom",
        plot.title = element_text(hjust = 0.5, size = 20),
        axis.title.x = element_text(size = 20),
        axis.title.y = element_text(size = 20),
        axis.text.x = element_text(angle = 45, hjust = 1, size = 15),
        axis.text.y = element_text(size = 15),
        legend.title = element_text(size = 20),
        legend.text = element_text(size = 15))
print(timeline)

ggsave(paste0(outputdir,"timeline.png"), timeline, width=13, height=8)

