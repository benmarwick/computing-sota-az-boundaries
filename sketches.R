
# exploring getting elevation data from 
# https://lidarportal.dnr.wa.gov/


# wilderness peak https://lidarportal.dnr.wa.gov/#47.51853:-122.09364:16
url <- paste0("https://lidarportal.dnr.wa.gov/download?geojson=%7B%22type%22%3A%22Polygon%22%2C%22",
              "coordinates%22%3A%5B%5B%5B",
               "-122.0952", "%2C", "47.5165", "%5D%2C%5B",
               "-122.0952", "%2C", "47.5212", "%5D%2C%5B", 
               "-122.0889", "%2C", "47.5212", "%5D%2C%5B",
               "-122.0889", "%2C", "47.5165", "%5D%2C%5B",
               "-122.0952", "%2C", "47.5165", "%5D%5D%5D%7D",
               "&ids=1603")

# simplify bounding box coords
bbx_m <- 
bbx_st_poly %>% 
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
              "&ids=1603")

# send our query to the LIDAR portal, unzip the response and import the tif file
library(httr2)
req <- request(url)
resp <- req %>% req_perform()
v = resp_body_raw(resp)
writeBin(v, "data.zip")
unzip("data.zip", 
      exdir = "from_url_req/")
the_raster_file <- 
  list.files(path = here::here("from_url_req/"),
             pattern = "*.tif",
             full.names = TRUE,
             ignore.case = TRUE,
             recursive = TRUE)
# import into our R session
the_raster <- terra::rast(the_raster_file)

# re-project to WGS84 and crop to bbox, this takes a few moments
myExtent <-  project(the_raster, crs(bbx_st_poly))
myExtentCropped <- terra::crop(myExtent, bbx_st_poly)

# take a look
ggplot() +
  geom_spatraster(data = myExtentCropped) +
  scale_fill_viridis_c(na.value = "white",
                       name = "Elevation (ft)") +
  annotation_scale(location = "bl", 
                   width_hint = 0.5,
                   pad_y = unit(0.1, "cm"),
                   pad_x = unit(0.5, "cm"),
                   style =  "ticks") +
  coord_sf()

# subset the AZ that is in this bbox
clamped <- myExtentCropped
clamped[clamped < this_summit_point_az$az_lower_contour_ft] <- NA

# get extent of the AZ raster as polygon
az_poly <- st_as_sf(as.polygons(clamped > -Inf))

ggplot() +
  geom_spatraster(data = clamped) +
  geom_sf(data = az_poly,
          colour = "red",
          fill = NA) +
  scale_fill_viridis_c(na.value = "white",
                       name = "Elevation (ft)") +
  annotation_scale(location = "bl", 
                   width_hint = 0.5,
                   pad_y = unit(0.1, "cm"),
                   pad_x = unit(0.5, "cm"),
                   style =  "ticks") +
  coord_sf()

# if there are multiple polygons, we only want the one that 
# contains the summit point when we have multipolys, 
# we just want the one with the summit in it

# dissolve all into one polygon
df_union_cast <- sf::st_union(sf::st_as_sf(az_poly))
df_union_cast <- st_cast(df_union_cast, "POLYGON")

poly_with_summit <- 
  apply(st_is_within_distance(df_union_cast, 
                              this_summit_point, 
                              sparse = FALSE,
                              dist = 10), 2, # within or 10 m outside of, because some 
        # summits are just outside of their
        # nearest polygon
        function(col) { 
          df_union_cast[which(col), ]
        })[[1]]

ggplot() +
  geom_sf(data = df_union_cast) +
  geom_sf(data = this_summit_point) +
  coord_sf()




