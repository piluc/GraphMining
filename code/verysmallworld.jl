using Graphs
using StatsBase

function diameter_lower_upper_bound(graph::String)::Tuple{Int64,Int64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    x::Int64 = rand(1:nv(g))
    d::Array{Int64} = gdistances(g, x)
    lb::Int64 = maximum(d)
    ub = 2 * lb
    return lb, ub
end

function diameter_lower_upper_bound(graph::String, k::Int64)::Tuple{Int64,Int64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    x::Array{Int64} = sample(1:nv(g), k, replace = false)
    lb::Int64 = 0
    ub::Int64 = nv(g)
    for i in 1:k
        d::Array{Int64} = gdistances(g, x[i])
        height::Int64 = maximum(d)
        lb = max(lb, height)
        ub = min(ub, 2 * height)
    end
    return lb, ub
end

function max_degree_node(g)
    degree = degree_centrality(g, normalize = false)
    maxdegree, u = findmax(degree)
    return u
end

function ifub(g, u)
    d = gdistances(g, u)
    nbfs = 1
    i, lb = maximum(d), 0
    for u in 1:nv(g)
        if d[u] == i
            du = gdistances(g, u)
            nbfs = nbfs + 1
            eccu = maximum(du)
            if lb < eccu
                lb = eccu
            end
        end
    end
    while lb <= 2 * (i - 1)
        i = i - 1
        for u in 1:nv(g)
            if d[u] == i
                du = gdistances(g, u)
                nbfs = nbfs + 1
                eccu = maximum(du)
                if lb < eccu
                    lb = eccu
                end
            end
        end
    end
    return lb, nbfs
end