function degree_distribution(graph::String)::Vector{Float64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    d::Array{Int64} = degree_centrality(g, normalize = false)
    return [count(==(i), d) for i in 1:maximum(d)] ./ nv(g)
end

function pareto(graph::String, perc::Float64, r::Bool)::Float64
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    n_bottom::Int64 = trunc(nv(g) * perc)
    d::Array{Int64} = degree_centrality(g, normalize = false)
    p::Array{Int64} = sortperm(d, rev = r)
    sg::SimpleGraph{Int64}, _ = induced_subgraph(g, p[1:n_bottom])
    n_owned_edges::Int64 = 0
    for i in 1:n_bottom
        n_owned_edges = n_owned_edges + d[p[i]]
    end
    n_owned_edges = n_owned_edges - ne(sg)
    return n_owned_edges / ne(g)
end

function er(n::Int64, p::Float64)::SimpleDiGraph{Int64}
    g::SimpleDiGraph{Int64} = SimpleDiGraph{Int64}(n)
    gd::Geometric{Float64} = Geometric(p)
    edge_index::Int64 = 0
    gap::Int64 = rand(gd)
    while (edge_index + gap < (nv(g) * nv(g)))
        edge_index = edge_index + gap
        println(edge_index, " ", gap)
        src::Int64 = div(edge_index, nv(g))
        dst::Int64 = edge_index - src * nv(g)
        add_edge!(g, src + 1, dst + 1)
        edge_index = edge_index + 1
        gap = rand(gd)
    end
    return g
end