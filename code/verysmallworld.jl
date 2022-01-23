function diameter_lower_upper_bound(graph::String)::Tuple{Int64,Int64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    lb::Int64 = maximum(gdistances(g, rand(1:nv(g))))
    return lb, 2 * lb
end

function diameter_lower_upper_bound(graph::String, k::Int64)::Tuple{Int64,Int64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    x::Array{Int64} = sample(1:nv(g), k, replace = false)
    lb::Int64, ub::Int64 = 0, nv(g)
    for i in 1:k
        height::Int64 = maximum(gdistances(g, x[i]))
        lb, ub = max(lb, height), min(ub, 2 * height)
    end
    return lb, ub
end

function two_sweep(graph::String)::Int64
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    lb::Int64, y::Int64 = findmax(gdistances(g, rand(1:nv(g))))
    return max(lb, maximum(gdistances(g, y)))
end

function max_degree_node(graph::String)::Int64
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    _, u = findmax(degree_centrality(g, normalize = false))
    return u
end

function ifub(graph::String, u::Int64)::Tuple{Int64,Int64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    d::Array{Int64}, nbfs::Int64 = gdistances(g, u), 1
    ordered_node_index::Array{Int64} = sortperm(d, rev = true)
    c::Int64, i::Int64 = 1, d[ordered_node_index[1]]
    L::Int64, U = 0, 2 * (i - 1) + 1
    while (L < U)
        L, nbfs = max(L, maximum(gdistances(g, ordered_node_index[c]))), nbfs + 1
        c = c + 1
        if (d[ordered_node_index[c]] == i - 1)
            i = i - 1
            U = 2 * (i - 1) + 1
        end
    end
    # for u in 1:nv(g)
    #     if d[u] == i
    #         lb = max(lb, maximum(gdistances(g, u)))
    #         nbfs = nbfs + 1
    #     end
    # end
    # while lb <= 2 * (i - 1)
    #     i = i - 1
    #     for u in 1:nv(g)
    #         if d[u] == i
    #             du = gdistances(g, u)
    #             nbfs = nbfs + 1
    #             eccu = maximum(du)
    #             if lb < eccu
    #                 lb = eccu
    #             end
    #         end
    #     end
    # end
    return L, nbfs
end