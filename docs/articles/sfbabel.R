## ------------------------------------------------------------------------
library(raster)
data("volcano")

## prepared with dput(lapply(locator(), round, 3))
xy_traverse <- do.call(cbind, structure(list(x = c(0.161, 0.186, 0.202, 0.228, 0.252, 0.27, 
0.285, 0.292, 0.309, 0.349, 0.382, 0.41, 0.446, 0.479, 0.552, 
0.607, 0.614, 0.591, 0.55, 0.506, 0.471, 0.45, 0.405, 0.387, 
0.375, 0.359, 0.343, 0.342, 0.344, 0.324, 0.262, 0.246, 0.22, 
0.206, 0.206), y = c(0, 0.029, 0.037, 0.053, 0.053, 0.06, 0.094, 
0.121, 0.155, 0.2, 0.219, 0.245, 0.264, 0.274, 0.286, 0.317, 
0.349, 0.384, 0.406, 0.423, 0.427, 0.445, 0.48, 0.496, 0.515, 
0.537, 0.584, 0.625, 0.661, 0.698, 0.698, 0.682, 0.631, 0.563, 
0.545)), .Names = c("x", "y")))

rastergrid <- raster(t(volcano[,ncol(volcano):1 ]))

zz <- extract(rastergrid, xy_traverse)
plot(rastergrid, col = viridis::viridis(10))
lines(xy_traverse[, 1:2])
plot(zz, type = "l")

## ------------------------------------------------------------------------
library(sf)
report <- st_sf(name = "epic traverse", st_sfc(st_linestring(cbind(xy_traverse, zz))))

plot(report)
print(report)

## ------------------------------------------------------------------------
library(spbabel)
map_table(report, v_atts = c("x_", "y_", "z_"))



