using Graphs
using StatsBase

function distances(graph::String, x)::Array{Int64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    d::Array{Int64} = gdistances(g, 1)
    return d
end

function degrees_of_separation(graph::String)::Float64
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    s::Int64 = 0
    for x::Int64 in vertices(g)
        d::Array{Int64} = gdistances(g, x)
        s = s + sum(d)
    end
    return s / (nv(g) * (nv(g) - 1))
end

# g = loadgraph("/Users/piluc/icloud/books/ars/grafi/slashdot.lg", "graph")
# degree = degree_centrality(g, normalize=false)
# println(maximum(degree))
# println(minimum(degree))
# c = is_connected(g)
# println(c)

# g = loadgraph("/Users/piluc/icloud/books/ars/grafi/slashdot.lg", "graph")
# frequencies = zeros(Int64, nv(g) - 1)
# for x in vertices(g)
#     d = gdistances(g, x)
#     f = counts(d, 1:nv(g) - 1)
#     global frequencies = frequencies + f
# end
# println(frequencies / (nv(g) * (nv(g) - 1)))

# frequencies = zeros(Int64, nv(g) - 1)
# k = 100 * trunc(log2(nv(g)))
# for e in 1:k
#     x = rand(1:nv(g))
#     d = gdistances(g, x)
#     f = counts(d, 1:nv(g)-1)
#     global frequencies = frequencies + f
# end
# maxzero = 0
# for i in 1:nv(g)-1
#     if (frequencies[i] > 0)
#         global maxzero = i
#     end
# end
# println("Maximum non zero value: ", maxzero)
# frequencies = frequencies / (k * (nv(g) - 1))
# println(frequencies[1:maxzero])