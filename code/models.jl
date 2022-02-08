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

function directed_erdos_renyi(n::Int64, p::Float64)::SimpleDiGraph{Int64}
    g::SimpleDiGraph{Int64} = SimpleDiGraph{Int64}(n)
    gd::Geometric{Float64} = Geometric(p)
    edge_index::Int64 = 0
    gap::Int64 = rand(gd)
    while (edge_index + gap < (nv(g) * nv(g)))
        edge_index = edge_index + gap
        src::Int64 = div(edge_index, nv(g))
        dst::Int64 = edge_index - src * nv(g)
        add_edge!(g, src + 1, dst + 1)
        edge_index = edge_index + 1
        gap = rand(gd)
    end
    return g
end

function erdos_renyi(n::Int64, p::Float64)::SimpleGraph{Int64}
    g::SimpleGraph{Int64} = SimpleGraph{Int64}(n)
    gd::Geometric{Float64} = Geometric(p)
    k::Int64 = 0
    gap::Int64 = rand(gd)
    while (k + gap < ((nv(g) * (nv(g) - 1)) / 2))
        k = k + gap
        u::Int64, v::Int64 = edge2nodes(nv(g), k)
        add_edge!(g, u, v)
        k = k + 1
        gap = rand(gd)
    end
    return g
end

function edge2nodes(n::Int64, e::Int64)::Tuple{Int64,Int64}
    u = n - 1 - floor(sqrt(-8 * e + 4 * n * (n - 1) - 7) / 2.0 - 0.5)
    v = e + u + 1 - n * (n - 1) / 2 + (n - u + 1) * (n - u) / 2
    return u, v
end

function nodes2edge(n::Int64, u::Int64, v::Int64)::Int64
    return (n * (n - 1) / 2) - ((n - (u - 1)) * (n - (u - 1) - 1) / 2) + v - u - 1
end

# Generate Erdos-Renyi graph between the set of nodes [n1] and
# the set of nodes [n2]. If n1=n2=n, the result is G_{n,p}.
function bipartite_erdos_renyi(n1::Int64, n2::Int64, p::Float64)
    gd::Geometric{Float64} = Geometric(p)
    edges::Vector{Pair{Int64,Int64}} = []
    edge_index::Float64 = -1
    gap::Float64 = rand(gd) + 1
    while (edge_index + gap < n1 * n2)
        edge_index = edge_index + gap
        src = div(edge_index, n2)
        dst = edge_index - n2 * src
        append!(edges, [Pair(src + 1, dst + 1)])
        gap = rand(gd) + 1
    end
    return edges
end

# Compute regions of nodes with same degree
function compute_regions(degree_sequence::Vector{Int64})::Vector{Pair{Int64,Int64}}
    n::Int64 = 1
    regions::Vector{Pair{Int64,Int64}} = []
    while (n <= length(degree_sequence))
        first = n
        degree = degree_sequence[n]
        while ((n < length(degree_sequence)) && (degree_sequence[n+1] == degree))
            n = n + 1
        end
        append!(regions, [first => n])
        n = n + 1
    end
    return regions
end

# Generate Chung-Lu graph
function chung_lu(degree_sequence::Vector{Int64}; verbose = false)::Vector{Pair{Int64,Int64}}
    regions::Vector{Pair{Int64,Int64}} = compute_regions(degree_sequence)
    volume = sum(degree_sequence)
    if (verbose)
        println("Number of regions: ", length(regions))
        println("Sum of degrees: ", volume)
    end
    edges::Vector{Pair{Int64,Int64}} = []
    for row_region_index in 1:length(regions)
        row_region = regions[row_region_index]
        if (verbose)
            println("ER graphs from region ", row_region_index, ": ", row_region)
        end
        for col_region_index in 1:length(regions)
            col_region = regions[col_region_index]
            # println("   ER graph to region ", col_region_index, ": ", col_region)
            p = (degree_sequence[row_region.first] * degree_sequence[col_region.first]) / volume
            # println("      ER probability: ", p)
            row_region_size = row_region.second - row_region.first + 1
            col_region_size = col_region.second - col_region.first + 1
            # println("      ", row_region_size, " rows and ", col_region_size, " columns")
            er_edges = bipartite_erdos_renyi(row_region_size, col_region_size, p)
            # println("      ", length(er_edges), " edge(s) generated")
            for edge in er_edges
                r = edge.first
                c = edge.second
                append!(edges, [Pair(row_region.first + r - 1, col_region.first + c - 1)])
            end
        end
    end
    return edges
end