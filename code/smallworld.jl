using LightGraphs
using StatsBase
# g = loadgraph("/Users/piluc/icloud/books/ars/grafi/florence.lg", "graph")

# d = gdistances(g, 1)
# println(d)

# s = 0
# for x in vertices(g)
#     local d = gdistances(g, x)
#     global s = s + sum(d)
# end
# println(s / (nv(g) * (nv(g) - 1)))

# g = loadgraph("/Users/piluc/icloud/books/ars/grafi/slashdot.lg", "graph")
# degree = degree_centrality(g, normalize=false)
# println(maximum(degree))
# println(minimum(degree))
# c = is_connected(g)
# println(c)

g = loadgraph("/Users/piluc/icloud/books/ars/grafi/slashdot.lg", "graph")
# frequencies = zeros(Int64, nv(g) - 1)
# for x in vertices(g)
#     d = gdistances(g, x)
#     f = counts(d, 1:nv(g) - 1)
#     global frequencies = frequencies + f
# end
# println(frequencies / (nv(g) * (nv(g) - 1)))

frequencies = zeros(Int64, nv(g) - 1)
k = 100 * trunc(log2(nv(g)))
for e in 1:k
    x = rand(1:nv(g))
    d = gdistances(g, x)
    f = counts(d, 1:nv(g) - 1)
    global frequencies = frequencies + f
end
maxzero = 0
for i in 1:nv(g) - 1
    if (frequencies[i] > 0)
        global maxzero = i
    end
end
println("Maximum non zero value: ",maxzero)
frequencies = frequencies / (k * (nv(g) - 1))
println(frequencies[1:maxzero])