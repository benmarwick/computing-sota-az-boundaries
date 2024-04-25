


# make a URL to see what the lidar coverage is like for a summit
# open the URL in the clipboard to paste into the browser
browseURL(
paste0(
  "https://lidarportal.dnr.wa.gov/#",
  this_summit$y, 
  ":",
  this_summit$x,
  ":13"
))

#------------------------------------------------------------------------------
# from https://www.jakelow.com/blog/using-wa-dnr-lidar-imagery-in-id
# get those IDs with this in the terminanal
# $ curl -s --compressed 'https://lidarportal.dnr.wa.gov/arcgis/services/lidar/wadnr_hillshade/MapServer/WmsServer?service=WMS&request=GetCapabilities' | xidel -s - -e '//Layer/Name' | paste -sd "," - | sed 's/,/%2C/g';2D

x <-  read_file ("lidar-ids.txt")

lidar_ids <- 
str_remove_all(x, "h") %>% 
  str_split("%2C") %>% 
  unlist() %>% 
  parse_number() %>% 
  -1 %>% 
  str_c( collapse = "%2C") 


#------------------------------------------------------------------------------

library(rvest)
library(httr)
library(tidyverse)

# get list of regions in the W7W association
# via API
sota_regions_w7w <- "https://api2.sota.org.uk/api/associations/w7w"
r <- GET(sota_regions_w7w)
dat <- 
  jsonlite::fromJSON(content(r, as = "text")) %>% 
  purrr::pluck("regions") %>% 
  tibble()

# get data on number of activations in each region in W7W

region_urls <- paste0("https://api2.sota.org.uk/api/regions/W7W/",
                      dat$regionCode)

# get all the data for each region, this take a few seconds
region_summits <- 
  map_dfr(region_urls,
          ~GET(.x) %>% 
            content(., as = "text")%>% 
            jsonlite::fromJSON() %>% 
            purrr::pluck("summits") %>% 
            tibble() )

# plot them
region_summits %>% 
  mutate(region = str_remove_all(shortCode, "-.*")) %>% 
  group_by(region) %>% 
  summarise(sum_activationCount = sum(activationCount)) %>% 
  arrange(desc(sum_activationCount)) %>% 
  ggplot() +
  aes(reorder(region, 
              -sum_activationCount),
      sum_activationCount) +
  geom_col() +
  xlab("SOTA region") +
  ylab("Number of activations")


#--------------------------------------------------------------------------
# group multiple similar rasters 
# with different resolutions

# here's one group of rasters with similar resolution
# m1 <- rast(the_raster_files[c(1)])
 m1 <- sprc(the_raster_files[c(1,2)])
 m1 <- terra::merge(m1, gdal=c("BIGTIFF=YES", "NUM_THREADS = ALL_CPUS") )

plot(m1) # hi res

# here's another group of rasters with similar resolution
m2 <- rast(the_raster_files[c(3)])
#m2 <- sprc(the_raster_files[c(3:4)])
#m2 <- terra::merge(m2, gdal=c("BIGTIFF=YES", "NUM_THREADS = ALL_CPUS") )

plot(m2) # low res

# in case CRS are not the same
crs(m1) <- crs(m2)

# https://gis.stackexchange.com/a/423700
e <- exactextractr::exact_resample(m2, #. low res raster,
                                   m1, #  high res raster
                                  'mean')
plot(e)
 
m <- terra::merge(e,   # output from previous
                  m1)  # high res
 
plot(m)

#------------------------------------------------------------------------------
# how to automate this merging of rasters of different resolutions?

# import into our R session, mostly there are multiple tif 
# files, but sometimes just one
if(length(the_raster_files) == 1){
  
  # just one raster
  m <- rast(the_raster_files)
  
} else {

  # more than one, and with different resolutions
  
rasters_res_tbl <- 
tibble(
  file = the_raster_files,
  res = map_dbl(the_raster_files, ~res(rast(.x))[[1]])
) %>% 
  # make sure hi res is first
  arrange(desc(res))

res_n <- unique(rasters_res_tbl$res)

# create a list of rasters where we've merged together files with the same
# resolution, if there are multiples
list_of_rasters <- vector("list", length = length(res_n))

for(i in 1:length(res_n)){
  
  the_res <- res_n[i]
  
  if(sum(rasters_res_tbl$res == the_res) == 1){
    # if just one raster of that resolution
    list_of_rasters[[i]] <- rast(rasters_res_tbl$file[ rasters_res_tbl$res == the_res ])
  } else {
    # if multiple raster files of that resolution
    list_of_rasters[[i]]  <-  sprc(rasters_res_tbl$file[ rasters_res_tbl$res == the_res ])
    list_of_rasters[[i]]  <- terra::merge(list_of_rasters[[i]], gdal=c("BIGTIFF=YES", "NUM_THREADS = ALL_CPUS") )
  }
  
}

# downsample the hi-res raster to match the low-res raster, assuming we
# have only two different resolutions of rasters here, and so only a list o
# of two items, hopefully this is true!

# in case CRS are not the same
  crs(list_of_rasters[[1]]) <-  crs(list_of_rasters[[2]])
  
  # https://gis.stackexchange.com/a/423700
  e <- exactextractr::exact_resample(list_of_rasters[[2]], #. low res raster,
                                     list_of_rasters[[1]], #  high res raster
                                     'mean')
  
  m <- terra::merge(e,   # output from previous
                    list_of_rasters[[1]])  # high res
  
}
  
#---------------------------------------------------------------------------




# exploring getting elevation data from 
# https://lidarportal.dnr.wa.gov/
# KG-141 and KG-142 are unusually large, done
# KG-041, KG-042 summit is about 20 m outside of the polygon, done
# KG-120 is abrupt on the south edge, needs a bigger raster, done
# KG-139 has abrupt edges, needs a bigger raster, done
# KG-143 has abrupt edges, needs a bigger raster, done
# KG_100 has abrupt edges, needs a bigger raster, done
# KG_118 has abrupt edges, needs a bigger raster, done


library(httr2)

az_elev_m <- 25 # AZ is area -25m elevation from summit

for(i in 1:nrow(gjsf_elev)){
  
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
rm(resp)
writeBin(v, "data.zip")
rm(v)
unzip("data.zip", 
      exdir = "from_url_req/")
unlink("data.zip")
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
  m <- terra::merge(m, gdal=c("BIGTIFF=YES", "NUM_THREADS = ALL_CPUS") )
}

# transform summit and bounding box coords 
# to the projection of LIDAR data
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
# geom_sf(data = this_summit_nad83) +
# geom_sf(data = az_poly,
#         colour = "red",
#         fill = NA) +
# scale_fill_viridis_c(na.value = "white",
#                      name = "Elevation (ft)") +
# annotation_scale(location = "bl",
#                  width_hint = 0.5,
#                  pad_y = unit(0.1, "cm"),
#                  pad_x = unit(0.5, "cm"),
#                  style =  "ticks") +
# coord_sf()

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
                              dist = 25), 2, # within or 10 m outside of, because some 
        # summits are just outside of their
        # nearest polygon
        function(col) { 
          df_union_cast[which(col), ]
        })[[1]]

# # now we see the single polygon that is the activation zone
ggplot() +
  geom_sf(data = poly_with_summit) +
  geom_sf(data = this_summit_nad83) +
  coord_sf() +
  annotation_scale(location = "bl", 
                   width_hint = 0.5,
                   pad_y = unit(0.1, "cm"),
                   pad_x = unit(0.5, "cm"),
                   style =  "ticks") 

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

# study the output to check if they look ok or not

poly_with_summit_max_linear_dim <- 
  map(az_files, ~.x %>% 
        st_simplify(dTolerance = 1e1) %>% 
        st_cast('MULTIPOINT') %>% 
        st_cast('POINT') %>% 
        st_distance %>% 
        max())


tibble(
  summit = names(map_dbl(poly_with_summit_max_linear_dim, pluck, 1) ),
  max_dim = map_dbl(poly_with_summit_max_linear_dim, pluck, 1)
) %>% View


