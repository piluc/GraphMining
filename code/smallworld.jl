using Graphs
using Plots
using StatsBase

function distances(graph::String, x::Int64)::Array{Int64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    d::Array{Int64} = gdistances(g, x)
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

function min_max_degree(graph::String)::Tuple{Int64,Int64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    degree::Array{Int64} = degree_centrality(g, normalize = false)
    return minimum(degree), maximum(degree)
end

function distance_distribution(graph::String)::Array{Float64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    dd::Array{Int64} = zeros(Int64, nv(g) - 1)
    for x::Int64 in vertices(g)
        dd = dd + counts(gdistances(g, x), 1:nv(g)-1)
    end
    return dd / (nv(g) * (nv(g) - 1))
end

function degrees_of_separation(dd::Array{Float64})::Float64
    last_distance::Int64 = findlast(x -> x > 0, dd)
    return dot(1:last_distance, dd[1:last_distance])
end

function distance_distribution(graph::String, k::Int64)::Array{Float64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    dd::Array{Int64} = zeros(Int64, nv(g) - 1)
    for _ in 1:k
        dd = dd + counts(gdistances(g, rand(1:nv(g))), 1:nv(g)-1)
    end
    return dd / (k * (nv(g) - 1))
end