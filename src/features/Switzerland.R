library(tidyverse)
library(openxlsx)
library(sf)
library(XML)
library(gdalUtilities)
library(terra)
library(exactextractr)

### CH shapefile

swmap = read_sf("/home/rstudio/project/Data/raw/Switzerland/shapefiles_bfs/ag-b-00.03-889-gg01g1/g1g01-shp_080214/G1G01.shp")

st_crs(swmap) <- 21781

swmap_wgs84 <- st_transform(swmap, 4326)

# Check if transformations did not produce distortions
par(mfrow = c(1, 2))
plot(st_geometry(swmap), main = "Original (LV03, EPSG:21781)")
plot(st_geometry(swmap_wgs84), main = "Nach WGS84 (EPSG:4326)")
par(mfrow = c(1, 1))



### Soil data

bbsw <- st_bbox(swmap_wgs84)

variables = c("bdod", "cfvo", "clay", "sand", "silt", "wv0010","wv1500", "wv003", "cec","nitrogen", "soc", "phh2o")
depth = c("5-15cm","15-30cm","30-60cm","60-100cm","100-200cm")

roi = sprintf("subset=X(%.6f,%.6f)&subset=Y(%.6f,%.6f)", bbsw["xmin"], bbsw["xmax"], bbsw["ymin"], bbsw["ymax"])
subsettingcrs = "SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
outputcrs = "OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"


voi = "nitrogen"
depth = "30-60cm"
quantile  = "Q0.5"
voi_layer = paste(voi, depth, quantile, sep = "_")

wcs_path = paste0("https://maps.isric.org/mapserv?map=/map/", voi, ".map")
wcs_service = "SERVICE=WCS"
wcs_version = "VERSION=2.0.1"
wcs_request = "request=GetCoverage"
format = "format=GEOTIFF_INT16"

url_request = paste(
  wcs_path,
  paste0("coverageid=", voi_layer),
  wcs_service, wcs_version, wcs_request,
  format, roi, subsettingcrs, outputcrs,
  sep = "&"
)

small_tiff = rast(url_request)

plot(small_tiff[[1]], main = "SoilGrids + Polygone")

plot(swmap_wgs84, add = TRUE, border = "black", lwd = 1)

swmap_wgs84$elev_mean_exact <- exact_extract(small_tiff[[1]], swmap_wgs84, 'mean')


### Response variable

dat = read.xlsx("/home/rstudio/project/Data/raw/Switzerland/Data_Muni_1999.xlsx")

dat = dat |> filter(year > 1899) %>% mutate(firsh = first_sector/(first_sector + second_sector + third_sector)) |>
  select(mun_id, year, firsh)
