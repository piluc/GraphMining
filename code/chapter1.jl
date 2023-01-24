using Graphs

g = loadgraph("graphs/japan.lg", "graph")
p = bfs_parents(g, 1)
println(p)
c = is_connected(g)
println(c)
g = loadgraph("graphs/notconnectedjapan.lg", "graph")
cc = connected_components(g)
println(cc)
