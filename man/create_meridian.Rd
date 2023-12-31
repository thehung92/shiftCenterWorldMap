% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_world_map_custom_center.R
\name{create_meridian}
\alias{create_meridian}
\title{create meridian at longitude}
\usage{
create_meridian(long, deviation = 1e-04)
}
\arguments{
\item{long}{longitude from -180 to 180 degree}

\item{deviation}{default to 1e-4, around the unit of second}
}
\value{
sfc of polygon
}
\description{
define a long & slim polygon that overlaps the meridian line & set its CRS to match that of world
}
