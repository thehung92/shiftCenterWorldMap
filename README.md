
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shiftCenterWorldMap

<!-- badges: start -->
<!-- badges: end -->

The goal of shiftCenterWorldMap is to vizualize a fish-eyed world
(robinson projection) with the center of the map on your area of
interest. The edge of region is also densify with st_segmentize. \[shift
center world map along equator\]

<figure>
<img src="man/figures/animation-world.gif" alt="rotate-world" />
<figcaption aria-hidden="true">rotate-world</figcaption>
</figure>

## Installation

You can install the development version of shiftCenterWorldMap from
[GitHub](https://github.com/thehung92/shiftCenterWorldMap) with:

``` r
# install.packages("devtools")
devtools::install_github("thehung92/shiftCenterWorldMap")
```

## Example

Create world map in robinson project with the center at lon:lat=100:0
and plot with ggplot

``` r
library(shiftCenterWorldMap)
#> The legacy packages maptools, rgdal, and rgeos, underpinning the sp package,
#> which was just loaded, will retire in October 2023.
#> Please refer to R-spatial evolution reports for details, especially
#> https://r-spatial.org/r/2023/05/15/evolution4.html.
#> It may be desirable to make the sf package available;
#> package maintainers should consider adding sf to Suggests:.
#> The sp package is now running under evolution status 2
#>      (status 2 uses the sf package in place of rgdal)
library(ggplot2)
library(sf)
#> Linking to GEOS 3.11.0, GDAL 3.5.3, PROJ 9.1.0; sf_use_s2() is TRUE
## basic example code
center = 100
sf.world = create_world_map_custom_center(center)
#> Spherical geometry (s2) switched off
#> although coordinates are longitude/latitude, st_intersection assumes that they
#> are planar
#> Warning: attribute variables are assumed to be spatially constant throughout
#> all geometries
#> Spherical geometry (s2) switched on
#> Spherical geometry (s2) switched off
#> Warning in st_cast.sf(., to = "POLYGON"): repeating attributes for all
#> sub-geometries for which they may not be constant
ggplot() +
  geom_sf(data = sf.world)
```

<img src="man/figures/README-world-1.png" width="100%" />

You can see that the world map has a fish-eye shaped but the plot panel
is still a rectangle. Therefore, you cannot fill the color of the ocean
normally with theme(panel.background) because that method will fill the
whole rectangle with blue. What we want is a fish-eyed shape polygon
that we can plot as background before adding the worldmap layer.

``` r
sf.ocean = create_ocean_background(center)
# declare the robinson project with shifted center
myCrs = paste0('+proj=robin +lon_0=', center, ' +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84')
# the coord_sf is super important because
## you need to declare coordinate reference system (CRS) you want to plot for all layers
## you also need to declare the default crs 4326 so that ggplot know to interpret the non-sf layer as degree and in the lon:lat=0:0 degree.
map = ggplot() +
  geom_sf(data = sf.ocean, fill ="lightskyblue", alpha = 0.5) +
  geom_sf(data = sf.world) +
  coord_sf(crs = myCrs, default_crs = st_crs(4326)) +
  theme(panel.background = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank())
map
```

<img src="man/figures/README-ocean-1.png" width="100%" />

Sometime, you want to have the graticule grid so you have some idea
about the coordinate of the location you are looking at

``` r
map2 = map +
  # custom grid line every 20degree longitude and every 10 degree latitude
  scale_x_continuous(breaks = seq(-180, 180, 20)) +
  scale_y_continuous(breaks = seq(-90, 90, 10)) +
  theme(panel.grid = element_line(colour = "deepskyblue",
                                  linetype = 3,
                                  linewidth = 0.2))
map2
```

<img src="man/figures/README-theme-1.png" width="100%" />

the end result is a ggplot object and you should be able to save it to
file with ggsave
