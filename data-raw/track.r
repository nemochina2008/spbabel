#plot(1)
#x <- locator(15)
d <- structure(list(x = c(0.773059468760082, 0.9054608022368, 1.06109043983224, 
                          1.19349177330896, 1.27014517690074, 1.26782234648887, 1.17258629960211, 
                          1.16097214754275, 0.965854392945478, 0.714988708463276, 0.682469082697064, 
                          0.738217012581998, 0.840421550704377, 0.954240240886117, 1.03786213571352
), y = c(0.668657757117955, 0.70944799535154, 0.787890761185357, 
         0.841231841952353, 0.935363160952934, 1.34012783265543, 1.31188843695526, 
         1.22717024985474, 1.0702847181871, 1.06714700755375, 1.25854735618826, 
         1.34640325392214, 1.34326554328879, 1.34326554328879, 1.34326554328879
)), .Names = c("x", "y"))
library(tibble)
vertices <- tibble(x_ = d$x, y_  = d$y, z_ = rnorm(15), 
                   t_ = sort(Sys.time() + runif(15, 1, 1e5)), 
                   vertex_ = seq(15))

bXv <- tibble(vertex_ = vertices$vertex_, branch_ = c(rep(1, 10), rep(2, 5)))
b <- tibble(branch_ = c(1, 2), object_ = c(1, 2))
o <- tibble(name = c("a", "b"), object_  = c(1, 2))

track <- spbabel::p1table(list(o = o, b = b, bXv = bXv, v = vertices))

devtools::use_data(track)
