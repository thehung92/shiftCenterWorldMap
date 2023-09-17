#' segmentize the polygon so that we can have smoother line after projection
#'
#' The polygon need to be cast into POLYGON for the shape to not get distorted
#' @param sf sf of the polygon to smooth out
#' @return sf segmentized on the slice side
#' @export
segmentize_polygon <- function(sf, crs = myCrs) {
  sf_use_s2(FALSE) # this debug will make st_make_valid turn duplicate vertex into 1 vertex
  # sf object that contain the geounit cross the split line # and need to be clean
  sf = st_make_valid(sf)
  valid = st_is_valid(sf, reason = FALSE) # check if the geometry are valid
  # cast the multi polygon into polygon if the area > 1e8
  indices = which(as.numeric(st_area(sf)) > 1e8 & st_geometry_type(sf) == "MULTIPOLYGON")
  sf.castPoly = sf[indices,] %>%
    # this line is necessary to convert all sfg to multipolygon
    st_cast(to = "MULTIPOLYGON") %>%
    st_cast(to = "POLYGON")
  # segmentize on the cast poly
  sf.densePoly = sf.castPoly %>%
    st_segmentize(dfMaxLength = units::set_units(0.2, "degree"))
  # join with the !indices value
  sf2 = sf[-indices,] %>%
    bind_rows(sf.densePoly)
  # summarize into multi polygon again for other operation
  sf3 = sf2 %>% group_by(geounit) %>%
    summarise(geometry = st_combine(geometry))
  return(sf3)
}
