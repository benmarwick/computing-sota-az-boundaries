
# exploring getting elevation data from 
# https://lidarportal.dnr.wa.gov/

library(httr2)

az_elev_m <- 25 # AZ is area -25m elevation from summit

for(i in 140:nrow(gjsf_elev)){
  
  this_summit <- gjsf_elev[i, ] 
  this_square <- gjsf_elev_buf_sq_df[i, ]
  
  print(paste0("Starting work on the AZ for ", this_summit$id,
               "..."))

# simplify bounding box coords
bbx_m <- 
  gjsf_elev_buf_sq_df[i, ] %>% 
  st_cast("POINT") %>% 
  st_coordinates()

# construct URL to query the LIDAR data portal using our bbox coords
url <- paste0("https://lidarportal.dnr.wa.gov/download?geojson=%7B%22type%22%3A%22Polygon%22%2C%22",
              "coordinates%22%3A%5B%5B%5B",
              bbx_m[1,1], "%2C", bbx_m[1,2], "%5D%2C%5B",
              bbx_m[2,1], "%2C", bbx_m[2,2], "%5D%2C%5B", 
              bbx_m[3,1], "%2C", bbx_m[3,2], "%5D%2C%5B",
              bbx_m[4,1], "%2C", bbx_m[4,2], "%5D%2C%5B",
              bbx_m[5,1], "%2C", bbx_m[5,2], "%5D%5D%5D%7D",
              "&ids=",
              "1615", "%2C",   # East Cascades South 2020 DTM (not hillshade)
              "1609", "%2C",   # East Cascades North 2020 DTM (not hillshade)
              "1501", "%2C",   # King County East 2021 DTM (not hillshade)
              "1603"           # King County East 2021 DTM (not hillshade)
                               # 
)

print(paste0("Downloading LIDAR data for ", this_summit$id,
             "..."))

# send our query to the LIDAR portal, unzip the response and import the tif file
req <- request(url)
resp <- req %>% req_perform()
v = resp_body_raw(resp)
writeBin(v, "data.zip")
unzip("data.zip", 
      exdir = "from_url_req/")
the_raster_files <- 
  list.files(path = here::here("from_url_req/"),
             pattern = "*.tif",
             full.names = TRUE,
             ignore.case = TRUE,
             recursive = TRUE)

# import into our R session, mostly there are multiple tif 
# files, but sometimes just one
if(length(the_raster_files) == 1){
  m <- rast(the_raster_files)
} else {
  m <- sprc(the_raster_files)
  m <- merge(m)
}

# transform to projection of LIDAR data
this_square_nad83 <- st_transform(this_square, st_crs(m))
this_summit_nad83 <- st_transform(this_summit, st_crs(m))

# subset LIDAR data that fills just this square
lidar_cropped <- 
  terra::crop(m, this_square_nad83)

# delete downloaded files
unlink(here::here("from_url_req/"), recursive = TRUE)

# # take a look
# ggplot() +
#   geom_spatraster(data = lidar_cropped) +
#   geom_sf(data = this_summit_nad83) +
#   geom_sf(data = this_square_nad83,
#           fill = NA) +
#   scale_fill_viridis_c(na.value = "white",
#                        name = "Elevation (ft)") +
#   annotation_scale(location = "bl",
#                    width_hint = 0.5,
#                    pad_y = unit(0.1, "cm"),
#                    pad_x = unit(0.5, "cm"),
#                    style =  "ticks") +
#   coord_sf()

# get max elevation in this area
lidar_cropped_max_elev_ft <- minmax(lidar_cropped)[2]

# define elevation contour that bounds the AZ
this_summit_point_az <- 
  this_summit_nad83 %>% 
  mutate(lidar_cropped_max_elev_ft = lidar_cropped_max_elev_ft, 
         lidar_cropped_max_elev_m = lidar_cropped_max_elev_ft / 3.2808399,
         az_lower_contour = ifelse(elev_m <= lidar_cropped_max_elev_m,
                                   elev_m - az_elev_m,         
                                   lidar_cropped_max_elev_m - az_elev_m ),  # SOTA summit data does not always match raster data
         az_lower_contour_ft = az_lower_contour * 3.2808399) 

# subset the summit point that is in this bbox
lidar_cropped[lidar_cropped < this_summit_point_az$az_lower_contour_ft] <- NA

# # take a look
# ggplot() +
#   geom_spatraster(data = lidar_cropped) +
#   geom_sf(data = this_summit_nad83) +
#   geom_sf(data = this_square_nad83,
#           fill = NA) +
#   scale_fill_viridis_c(na.value = "white",
#                        name = "Elevation (ft)") +
#   annotation_scale(location = "bl", 
#                    width_hint = 0.5,
#                    pad_y = unit(0.1, "cm"),
#                    pad_x = unit(0.5, "cm"),
#                    style =  "ticks") +
#   coord_sf()

# get extent of the AZ raster as polygon
az_poly <- st_as_sf(as.polygons(lidar_cropped > -Inf))

# ggplot() +
#   geom_sf(data = this_summit_nad83) +
#   geom_sf(data = az_poly,
#           colour = "red",
#           fill = NA) +
#   scale_fill_viridis_c(na.value = "white",
#                        name = "Elevation (ft)") +
#   annotation_scale(location = "bl",
#                    width_hint = 0.5,
#                    pad_y = unit(0.1, "cm"),
#                    pad_x = unit(0.5, "cm"),
#                    style =  "ticks") +
#   coord_sf()

# if there are multiple polygons, we only want the one that 
# contains the summit point when we have multipolys, 
# we just want the one with the summit in it

# dissolve all into one polygon
df_union_cast <- sf::st_union(sf::st_as_sf(az_poly))
df_union_cast <- st_cast(df_union_cast, "POLYGON")

poly_with_summit <- 
  apply(st_is_within_distance(df_union_cast, 
                              this_summit_nad83, 
                              sparse = FALSE,
                              dist = 10), 2, # within or 10 m outside of, because some 
        # summits are just outside of their
        # nearest polygon
        function(col) { 
          df_union_cast[which(col), ]
        })[[1]]

# # now we see the single polygon that is the activation zone
# ggplot() +
#   geom_sf(data = poly_with_summit) +
#   geom_sf(data = this_summit_nad83) +
#   coord_sf()

poly_with_summit <- st_as_sf(st_transform(poly_with_summit, st_crs(this_summit)))

print(paste0("Saving GeoJSON file for ", this_summit$id,
             "..."))

# write AZ polygon to a GeoJSON file
file_name <- paste0("output/", str_replace_all(this_summit$id, "/|-", "_"), 
                    ".geojson")

# export AZ polygon as a GeoJSON file
geojsonio::geojson_write(poly_with_summit, 
                         file = here::here(file_name),
                         quiet = TRUE)


}

