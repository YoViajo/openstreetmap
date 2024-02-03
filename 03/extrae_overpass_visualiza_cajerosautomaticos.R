# Instala las librerías si aún no lo has hecho
#install.packages("osmdata")
#install.packages("mapview")
#install.packages("dplyr")

# Carga las librerías
library(osmdata)
library(mapview)
library(dplyr)

# Función para convertir coordenadas y radio en una bounding box
create_bbox <- function(latitude, longitude, radius_km) {
  earth_radius <- 6371  # Radio de la Tierra en km
  delta_lat <- (radius_km / earth_radius) * (180 / pi)
  delta_lon <- (radius_km / (earth_radius * cos(latitude * pi / 180))) * (180 / pi)
  
  bbox <- c(
    longitude - delta_lon,
    latitude - delta_lat,
    longitude + delta_lon,
    latitude + delta_lat
  )
  
  return(bbox)
}

# Coordenadas del centro de la ciudad
latitude <- -17.783330
longitude <- -63.182126

# Área de influencia (en km)
radius_km <- 20

# Crea una bounding box
bbox <- create_bbox(latitude, longitude, radius_km)

# Define la consulta Overpass
overpass_query <- opq(bbox = bbox) %>%
  add_osm_feature(key = "amenity", value = "atm")

# Obten los datos de los cajeros automáticos y conviértelos en un objeto sf
atm_data <- overpass_query %>%
  osmdata_sf()

# Filtra los cajeros automáticos usando la columna "amenity" con dplyr
atm_sf <- atm_data$osm_points %>%
  filter(amenity == "atm")

# Visualiza los cajeros automáticos en un mapa
mapview(atm_sf, zcol = "name", popup = TRUE)

