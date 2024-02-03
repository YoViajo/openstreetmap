# Instala las librerías si aún no lo has hecho
install.packages("osmdata", dependencies = TRUE)
install.packages("dplyr")
install.packages("sf")
install.packages("ggplot2")
install.packages("ggspatial")

# Carga las librerías
library(osmdata)
library(dplyr)
library(sf)
library(ggplot2)
library(ggspatial)

# Define el centro de la ciudad de Santa Cruz
centro <- c(-63.182126, -17.783330)

# Calcula la extensión del área de influencia (20 km en todas las direcciones)
extension <- 20000

# Calcula las coordenadas del cuadro delimitador
bbox <- c(centro[1] - extension, centro[2] - extension, centro[1] + extension, centro[2] + extension)

# Define la consulta Overpass en formato Overpass QL
overpass_query <- paste0("node['amenity'='atm'](bbox);")

# Obten los datos de los cajeros automáticos y conviértelos en un objeto sf
atm_data <- opq(bbox = bbox) %>%
  set_overpass_query(overpass_query) %>%
  osmdata_sf()

# Filtra los cajeros automáticos usando la columna "amenity" con dplyr
atm_sf <- atm_data$osm_points %>%
  filter(amenity == "atm")

# Descarga los datos del mapa base
map_base <- opq(bbox = bbox) %>%
  add_osm_feature(key = "highway") %>%
  osmdata_sf()

# Crea el gráfico estático
atm_plot <- ggplot() +
  geom_sf(data = map_base$osm_lines, color = "gray", size = 0.1) +
  geom_sf(data = atm_sf, color = "red", size = 2, shape = 21, fill = "white") +
  coord_sf(xlim = bbox[c(1, 3)], ylim = bbox[c(2, 4)], expand = FALSE) +
  theme_minimal() +
  theme(plot.background = element_rect(fill = "white"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank())

# Crea el subdirectorio "salida" si no existe
if (!dir.exists("salida")) {
  dir.create("salida")
}

# Guarda el gráfico como un archivo PNG en el subdirectorio "salida"
ggsave("salida/atm_plot.png", plot = atm_plot, width = 10, height = 8, dpi = 300)
