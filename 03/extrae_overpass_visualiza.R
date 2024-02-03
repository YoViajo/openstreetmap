# Instala las librerías si aún no lo has hecho
#install.packages("osmdata")
#install.packages("mapview")

# Carga las librerías
library(osmdata)
library(mapview)

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

# Coordenadas del centro de la ciudad de Santa Cruz
latitude <- -17.783330
longitude <- -63.182126

# Área de influencia (en km)
radius_km <- 30

# Crea una bounding box
bbox <- create_bbox(latitude, longitude, radius_km)

# Define la consulta Overpass
overpass_query <- opq(bbox = bbox) %>%
  add_osm_feature(key = "amenity", value = "pharmacy")

# Obten los datos de las farmacias y conviértelos en un objeto sf
pharmacies_sf <- overpass_query %>%
  osmdata_sf() %>%
  osm_points %>%
  subset(amenity == "pharmacy")

# Visualiza las farmacias en un mapa con fondo CartoDB Positron
mapview(pharmacies_sf, zcol = "name", popup = TRUE, map.types = "CartoDB.Positron")
