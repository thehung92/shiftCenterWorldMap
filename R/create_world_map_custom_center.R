#' create world map as sf object
#'
#' @param name description
#' @return sf object
#' @examples
#' sf = create_world_map_custom_center()
#' ggplot() + geom_sf(data =sf)
#' @export
create_world_map_custom_center <- function(center = 100, class = "sf") {
  # create world map as sf object
  sf.world = rnaturalearth::ne_countries(scale = "medium", returnclass = class)
  # shift meridian at the new longitude
  if (center > 0) {
    split = center - 180
  } else {
    split = center + 180
  }
  # # error in doing geometric operations on sf crossing the date line # disable use_s2 to debug
  # sf_use_s2(FALSE)
  # sf.world2 <- sf.world %>% st_difference(meridian.split)
  # shift the prime meridian to lon_0 = 100 # and keep the WGS84 projection
  myCrs = paste0('+proj=longlat +lon_0=', center, ' +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84')
  # split the world dataset to get the difference bw the countries's polygon and the meridian.split
  sf.world3 = sf.world %>%
    st_break_antimeridian(lon_0 = center) %>%
    st_transform(crs = myCrs)
  # get index of the feature that pass through the 180 longitude and join the polygons at the old split
  indices = which(sf.world3$geounit %in% c("Russia", "Antarctica"))
  df.fields = sf.world3[indices,] %>%
    st_drop_geometry() %>%
    distinct()
  polygons.join = sf.world3[indices,] %>%
    group_by(geounit) %>%
    summarise(geounit = first(geounit),
              geometry = st_union(geometry)) %>%
    left_join(df.fields, ., by = "geounit") %>%
    st_as_sf()
  # join the merged polygons with the world data
  sf.world4 = sf.world3[-indices,] %>%
    bind_rows(polygons.join)
  # # find the indices of geounit that intersect with the meridian.split
  # # after re-projection, the meridian split still happen at 180
  # meridian.split = create_meridian(split) %>%
  #   st_transform(crs = myCrs)
  # indices = st_make_valid(sf.world4) %>%
  #   st_intersects(meridian.split, sparse = TRUE) %>%
  #   as.matrix() %>% which()
  # # segmentize the geounit that intersect the split meridian line
  # sf.smooth = sf.world4[indices,] %>%
  #   segmentize_polygon() %>%
  #   st_transform(crs = myCrs)
  # sf.world5 = sf.world4[-indices,] %>%
  #   bind_rows(sf.smooth)
  # segmentize the whole map
  sf.world5 = sf.world4 %>%
    segmentize_polygon(crs = myCrs)
  # robinson projection with custom center
  # transform at this step is important because early robinson transform cause the polygon not joined properly
  myCrs = paste0('+proj=robin +lon_0=', center, ' +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84')
  sf.world6 = sf.world5 %>%
    st_transform(crs = myCrs)
  # ggplot(sf.world6) + geom_sf() + coord_sf(crs = myCrs)
  return(sf.world6)
}
#' create meridian at longitude
#'
#' define a long & slim polygon that overlaps the meridian line & set its CRS to match that of world
#' @param long longitude from -180 to 180 degree
#' @param deviation default to 1e-4, around the unit of second
#' @return sfc of polygon
#' @export
create_meridian <- function(long, deviation = 1e-4) {
  # this is important because the longitude need to be <=180
  st_polygon(x = list(rbind(c(long - deviation, 90),
                            c(long, 90),
                            c(long, -90),
                            c(long - deviation, -90),
                            c(long - deviation, 90)))) %>%
    st_sfc(crs = st_crs(4326)) %>%
    st_sf()
}
#' object ocean as an oval for prime meridian at custom longitude
#'
#' @param long longitude of the custom center
#' @return sf object as oval polygon
#' @export
create_ocean_background <- function(long) {
  bbox = c(-180, -90, 180, 90)
  bbox[1] = bbox[1] + long
  bbox[3] = bbox[3] + long
  ocean = bb_earth(projection = "WGS84",
                   stepsize = 1,
                   earth.datum = 4326,
                   bbx = bbox,
                   buffer = 1e-06) %>%
    st_as_sf()
  return(ocean)
}

#'
