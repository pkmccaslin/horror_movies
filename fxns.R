
# A .R script that contains commonly used functions for cleaning and exploratory analysis

library(tidyverse)
library(vroom)
library(janitor)
library(sf)
library(viridis)
library(leaflet)
library(htmltools)


#does a standard group_by and count() with percentage
grouper <- function(input_df, group_by_column, new_column_name = "n()"){
  output_df <- input_df %>%
    group_by(.data[[group_by_column]]) %>%
    summarise(temp_count = n()) %>%
    mutate(percent = temp_count/sum(temp_count)*100) %>%
    arrange(desc(percent)) %>%
    rename(!!new_column_name := temp_count)
  return(output_df)
}

#group/counts every column in input dataframe
group_count <- function(input_df, group_column_name='n()', state_filter=NA, start_col = 1){
  column_names <- colnames(input_df)
  if(!is.na(state_filter)){
    input_df <- input_df %>%
      filter(state == state_filter)
  }
  for (column in column_names[start_col:length(column_names)]){
    output <- grouper(input_df, column, group_column_name)
    print(output)
  }
}

grouper_sum <- function(input_df, group_by_column, sum_column, new_column_name = "n()"){
  output_df <- input_df %>%
    group_by(.data[[group_by_column]]) %>%
    summarise(temp_count = sum(.data[[sum_column]])) %>%
    mutate(percent = temp_count/sum(temp_count)*100) %>%
    arrange(desc(percent)) %>%
    rename(!!new_column_name := temp_count)
  return(output_df)

}

#lowers case of every character column in a dataframe
lower_df <- function(input_df){
  names <- colnames(input_df)
  output_df <- input_df
  names <- colnames(output_df)
  for (name in names){
    if (is.character(output_df[[name]])){
      output_df[[name]] <- tolower(output_df[[name]])
      #print('yes')
    } else {
      output_df[[name]] <- output_df[[name]]
      #print('no')
    }
  }
  return(output_df)
}



clean_df <- function(input_df){
  temp <- input_df %>%
    clean_names() %>%
    lower_df()
  return(temp)

}

percent_change <- function(old_value, new_value) {
  if (old_value == 0) {
    return(NA)  # Or return Inf, depending on how you want to handle division by zero
  }
  ((new_value - old_value) / old_value) * 100
}

percent_difference <- function(value1, value2) {
  if (value1 == value2) {
    return(0)  # No difference
  }

  if (value1 == 0 && value2 == 0) {
    return(NA)  # Both values are zero
  }

  # Calculate the average of the two values
  avg <- (value1 + value2) / 2

  # Check if average is zero
  if (avg == 0) {
    return(NA)  # Or return Inf, depending on how you want to handle this case
  }

  # Calculate percent difference
  abs((value1 - value2) / avg) * 100
}

percent <- function(value1, value2){

  if (value1 == value2) {
    return(0)  # No difference
  }

  (value1/value2)*100
}

# a function to create a leaflet heatmap based on a column in your data
# This function generates an interactive leaflet map displaying a heatmap of a specified
# numerical column from a given dataframe. The map visualizes the data by coloring
# geographic polygons based on the values in the specified column. It also includes
# interactive labels that appear on hover, showing the value and a label for each
# polygon, as well as a legend to interpret the color scale.
#
# Args:
#   df: A spatial dataframe (of class sf or SpatialPolygonsDataFrame) containing
#       the geographic boundaries and the data to be visualized.
#   column: A string specifying the name of the numerical column in the 'df' that
#           will be used to determine the color intensity of the heatmap.
#   label_column: A string specifying the name of the column in 'df' that contains
#                 the labels to be displayed in the interactive popups/hovers for
#                 each geographic area.
#   title: A string to be used as the title of the color legend on the map.
#
# Variables:
#   pal: A colorNumeric palette generated using the "magma" color scheme (reversed)
#        and the range of values in the specified 'column' of the input dataframe 'df'.
#        This palette will be used to map numerical values to colors on the map.
#   labels: A list of HTML-formatted strings. Each string creates an interactive label
#           that appears when a polygon on the map is hovered over. The label displays
#           the value from the 'label_column' in bold and the corresponding value
#           from the specified 'column'.

heatmap <- function(df, column, label_column, title) {

  pal <- colorNumeric("magma", domain = df[[column]], reverse = T)

  labels <- sprintf(
    "<strong>%s</strong><br/>%g",
    df[[label_column]], df[[column]]
  ) %>% lapply(HTML)

  df %>%
    leaflet() %>%
    addTiles(options = providerTileOptions(minZoom = 5, maxZoom = 20)) %>%
    addPolygons(fillColor = ~pal(df[[column]]), color = "#444444", weight = 1, smoothFactor = 0.5,
                opacity = 1.0, fillOpacity = 0.8,
                highlightOptions = highlightOptions(color = "white", weight = 2,
                                                    bringToFront = TRUE),
                label = labels,
                labelOptions = labelOptions(
                  style = list("font-weight" = "normal", padding = "3px 8px"),
                  textsize = "8px",
                  direction = "auto")) %>%
    addLegend(pal = pal, values = df[[column]], opacity = 0.8, title = title,
              position = "topright")
}


# clean strings to be used for column names, etc.
clean_string <- function(x) {
  x %>%
    str_trim() %>%                        # remove leading/trailing whitesp
    str_to_lower() %>%                    # lowercase
    str_replace_all("&", "and") %>%       # replace & with "and"
    str_replace_all("[^a-z0-9]+", "_") %>% # replace non-alphanumeric with underscore
    str_replace_all("_{2,}", "_") %>%      # collapse multiple underscores
    str_remove("^_+|_+$")                 # remove leading/trailing underscores
}

# Function to create a viewport based on another shapefile's centroid
create_viewport <- function(input_sf, height = 0, width = 0, input_crs = 4326, shift_height = 0, shift_width = 0) {

  # Calculate the centroid of the input shapefile
  centroid <- st_centroid(st_union(input_sf))

  # Extract latitude and longitude from the centroid
  lat <- st_coordinates(centroid)[1, 2] + shift_height
  lon <- st_coordinates(centroid)[1, 1] + shift_width

  # Calculate the extent of the viewport
  xmin <- lon - (width / 2)
  xmax <- lon + (width / 2)
  ymin <- lat - (height / 2)
  ymax <- lat + (height / 2)

  # Create a rectangle as an sf object
  viewport <- st_polygon(list(rbind(c(xmin, ymin),
                                    c(xmin, ymax),
                                    c(xmax, ymax),
                                    c(xmax, ymin),
                                    c(xmin, ymin))))

  # Set the CRS of the rectangle
  viewport <- st_sf(geometry = st_sfc(viewport), crs = st_crs(input_crs))

  return(viewport)

}

# Negate the %in% function
Negate("%in%") -> `%notin%`