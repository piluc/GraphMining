# Section 3.2.1
function diameter_lower_upper_bound(graph::String)::Tuple{Int64,Int64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    lb::Int64 = maximum(gdistances(g, rand(1:nv(g))))
    return lb, 2 * lb
end

# Section 3.2.2
function diameter_lower_upper_bound(graph::String, k::Int64)::Tuple{Int64,Int64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    x::Array{Int64} = sample(1:nv(g), k, replace=false)
    lb::Int64, ub::Int64 = 0, nv(g)
    for i in 1:k
        height::Int64 = maximum(gdistances(g, x[i]))
        lb, ub = max(lb, height), min(ub, 2 * height)
    end
    return lb, ub
end

# Section 3.2.2
function two_sweep(graph::String)::Int64
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    lb::Int64, y::Int64 = findmax(gdistances(g, rand(1:nv(g))))
    return max(lb, maximum(gdistances(g, y)))
end

# Section 3.2.3
function max_degree_node(graph::String)::Int64
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    _, u = findmax(degree_centrality(g, normalize=false))
    return u
end

# Section 3.2.3
function ifub(graph::String, u::Int64)::Tuple{Int64,Int64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    d::Array{Int64}, nbfs::Int64 = gdistances(g, u), 1
    node_index::Array{Int64} = sortperm(d, alg=RadixSort, rev=true)
    c::Int64, i::Int64, L::Int64, U::Int64 = 1, d[node_index[1]], 0, nv(g)
    while (L < U)
        U, L = nv(g), max(L, maximum(gdistances(g, node_index[c])))
        nbfs, c = nbfs + 1, c + 1
        if (d[node_index[c]] == i - 1)
            U, i = 2 * (i - 1), i - 1
        end
    end
    return L, nbfs
end
