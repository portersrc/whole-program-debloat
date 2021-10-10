library(igraph)

# Create directed graph
dg = graph.formula(1-+2, 1-+3, 2-+4, 3-+4, 4-+5)
# check the graph object
# DG stands for directed network
dg
# list vertices
V(dg)
# list edges
E(dg)

V(dg)$name <- c('main', 'msg_filters_show', 'print_info_adv', 'msg_filters_to_str', 'uint32_to_optstr')
# V(dg)$name <- c('main', 'message_filters_show', 'print_info_adv', 'message_filters_to_str', 'uint32_to_optstr')
# E(g)$color[E(g)$weight == 1] <- 'green'
# E(dg)$color <- 'green'
E(dg)$color <- c('black', 'black', 'blue', 'green3', 'red')
E(dg)$lty <- c(1, 1, 4, 5, 3)

# star
coords <- layout_(g, as_star())
coords
#>    [,1] [,2]
#> [1,]  0  0
#> [2,]  1  0
#> [3,]  0  1
#> [4,] -1  0
#> [5,]  0 -1

# artistic diamond
# coords[1,1] = -.7
# coords[1,2] = 1
# coords[2,1] = -1
# coords[2,2] = 0
# coords[3,1] = 1
# coords[3,2] = .6
# coords[4,1] = .2
# coords[4,2] = -.2
# coords[5,1] = 1
# coords[5,2] = -1
# coords

# diamond
# coords[1,1] = 0
# coords[1,2] = 1
# coords[2,1] = -1
# coords[2,2] = 0
# coords[3,1] = 1
# coords[3,2] = 0
# coords[4,1] = 0
# coords[4,2] = -1
# coords[5,1] = 0
# coords[5,2] = -2
# coords

coords[1,1] = -3
coords[1,2] = 0
coords[2,1] = -1
coords[2,2] = -.5
coords[3,1] = -1
coords[3,2] = .5
coords[4,1] = 0
coords[4,2] = 0
coords[5,1] = 3
coords[5,2] = 0
coords

# plot graph
# plot(dg, edge.arrow.size=0.5, edge.color='green')
plot(dg,
     margin=-.4,
     vertex.size=70,
     vertex.color='lightyellow',
     vertex.label.color='black',
     vertex.label.font=2,
     edge.width=3,
     edge.arrow.size=1,
     edge.arrow.width=1,
     # edge.lty=2,
     layout=coords
     )

