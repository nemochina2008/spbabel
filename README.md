
[![Travis-CI Build Status](https://travis-ci.org/mdsumner/spbabel.svg?branch=master)](https://travis-ci.org/mdsumner/spbabel)

<!-- README.md is generated from README.Rmd. Please edit that file -->
Installation
------------

Spbabel can be installed directly from github:

``` r
devtools::install_github("mdsumner/spbabel")
```

spbabel: bisque or bouillon?
============================

Simple tools to flip between Spatial and tidy forms of data.

Spatial data in the `sp` package have a formal definition (extending class `Spatial`) that is modelled on shapefiles, and close at least in spirit to the [Simple Features definition](https://github.com/edzer/sfr). See [What is Spatial in R?](https://github.com/mdsumner/spbabel/wiki/What-is-Spatial-in-R) for more details.

Turning these data into long-form tables has been likened to making fish soup, which has a nice nod to the universal translator [babelfish](https://en.wikipedia.org/wiki/List_of_races_and_species_in_The_Hitchhiker%27s_Guide_to_the_Galaxy#Babel_fish). Soup may be thick and creamy as in the "twice cooked" *bisque* or clear as in the "boiled" *bouillon* and this analogy can be applied in many ways.

The `spbabel` package tries to avoid confusion by providing a more systematic encoding into the long-form with consistent naming and lossless ways to re-compose the original (or somewhat modified) objects.

The long-form version is similar to that implemented in:

-   sp's `as()` coercion for `SpatialLinesDataFrame` to `SpatialPointsDataFrame`
-   rasters's `geom()`
-   ggplot2's `fortify()`
-   gris's normalized tables

How does spbabel work
=====================

After quite a lot of experimentation (see spdplyr, sp.df, gris, babelfish) it seems that the long-form table of all coordinates, with object, branch, island-status, and order provides the best middle-ground for transferring between different representations of Spatial data.

Tables are always based on the "tibble" since it's a much better data frame.

The `sptable` function creates the table of coordinates with identifiers for object and branch, which is understood by `sptable<-` and `spFromTable` to "fortify" and vice versa.

The long-form table may seem very untidy, but it's not meant to be seen for normal use.

We can tidy this up by encoding the geometry data into a geometry-column, into nested data frames, or by normalizing to tables that store only one kind of data, or with recursive data structures such as lists of matrices. Each of these has strengths and weaknesses.

sptable: a round-trip-able extension to fortify
===============================================

The `sptable` function decomposes a Spatial object to a single table structured as a row for every coordinate in all the sub-geometries, including duplicated coordinates that close polygonal rings, close lines and shared vertices between objects.

Use the `sptable<-` replacement method to modify the underlying geometric attributes (here `x` and `y` is assumed no matter what coordinate system).

``` r
library(maptools)
#> Loading required package: sp
#> Checking rgeos availability: TRUE
data(wrld_simpl)
library(spbabel)
(oz <- subset(wrld_simpl, NAME == "Australia"))
#> class       : SpatialPolygonsDataFrame 
#> features    : 1 
#> extent      : 112.9511, 159.1019, -54.74973, -10.05167  (xmin, xmax, ymin, ymax)
#> coord. ref. :  +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0 
#> variables   : 11
#> Source: local data frame [1 x 11]
#> 
#>     FIPS   ISO2   ISO3    UN      NAME   AREA  POP2005 REGION SUBREGION
#>   (fctr) (fctr) (fctr) (int)    (fctr)  (int)    (dbl)  (int)     (int)
#> 1     AS     AU    AUS    36 Australia 768230 20310208      9        53
#> Variables not shown: LON (dbl), LAT (dbl)

## long-form encoding of objects
oztab <- sptable(oz)

##  make a copy to modify
woz <- oz
## modify the geometry on this object without separating the vertices from the objects
sptable(woz) <- sptable(woz) %>% mutate(x_ = x_ - 5)

# plot to compare 
plot(oz, col = "grey")
plot(woz, add = TRUE)
```

![](figure/README-unnamed-chunk-3-1.png)<!-- -->

We can also restructure objects, by mutating the value of object to be the same as "branch" we get individual objects from each.

``` r

pp <- sptable(wrld_simpl %>% filter(NAME == "Japan" | grepl("Korea", NAME)))
## explode (or "disaggregate"") objects to individual polygons
## here each branch becomes an object, and each object only has one branch
## (ignoring hole-vs-island status for now)
wone <- spFromTable(pp %>% mutate(object_ = branch_), crs = attr(pp, "crs"))
op <- par(mfrow = c(2, 1), mar = rep(0, 4))
plot(spFromTable(pp), col = grey(seq(0.3, 0.7, length = length(unique(pp$object)))))
plot(wone, col = sample(rainbow(nrow(wone), alpha = 0.6)), border = NA)
```

![](figure/README-unnamed-chunk-4-1.png)<!-- -->

``` r
par(op)
```

The long-form table is also ready for ggplot2 (although `geom_polygon` cannot handle islands with multiple holes - there is dev code to do this via geom\_holygon):

``` r
library(ggplot2)
ggplot(pp) + aes(x = x_, y = y_, fill = factor(object_), group = branch_) + geom_polygon()
```

![](figure/README-unnamed-chunk-5-1.png)<!-- -->

Why do this?
============

I want these things, and spbabel is the right compromise for where to start:

-   flexibility in the number and type/s of attribute stored as "coordinates", x, y, lon, lat, z, time, temperature, etc.
-   shared vertices
-   ability to store points, lines and areas together, sharing topology where appropriate
-   provide a flexible basis for conversion between other formats.
-   flexibility and ease of use
-   integration with database engines and other systems
-   integration with D3 via htmlwidgets, with shiny, and with gggeom ggvis or similar
-   data-flow with dplyr piping as the engine behind a D3 web interface

The ability to use [Manifold System](http://www.manifold.net/) seamlessly with R is a particular long-term goal, and this will be best done(TM) via dplyr "back-ending".
