using Graphs
using Plots
using SimpleWeightedGraphs
using Graphs
using LinearAlgebra
using StatsBase
using MultivariateStats
using SortingAlgorithms

function degrees_of_separation(graph::String)::Float64
     g::SimpleGraph{Int64} = loadgraph(graph, "graph")
     s::Int64 = 0
     for x::Int64 in vertices(g)
     d::Array{Int64} = gdistances(g, x)
     s = s + sum(d)
     end
     return s / (nv(g) * (nv(g) - 1))
     end

function distance_distribution(graph::String, k::Int64)::Array{Float64}
        g::SimpleGraph{Int64} = loadgraph(graph, "graph")
        dd::Array{Int64} = zeros(Int64, nv(g) - 1)
        for _ in 1:k
            dd = dd + counts(gdistances(g, rand(1:nv(g))), 1:nv(g)-1)
        end
        return dd / (k * (nv(g) - 1))
end 
	
function degrees_of_separation(dd::Array{Float64})::Float64
    last_distance::Int64 = findlast(x -> x > 0, dd)
    return dot(1:last_distance, dd[1:last_distance])
end

function plot_degrees_of_separation()
    A = []
    B = [] 
    for i in 1973:2022
        name = "IICalp" * string(i) * ".lg";
        g = loadgraph("icalp_by_year/" * name, "graph")
        cc = connected_components(g)
        lcc_index = argmax(length.(cc)) 
        sg = induced_subgraph(g, cc[lcc_index])
        savegraph("icalpcc.lg",sg[1])
        icalpcc = loadgraph("icalpcc.lg", "graph")
        push!(A, degrees_of_separation("icalpcc.lg"))
        push!(B, degrees_of_separation(distance_distribution("icalpcc.lg",100)))
    end

     x = 1973:2022
     fig1 = plot(x,A, title = "Degree of Separation", label ="Exact" )
     fig2 = plot!(x,B, title = "Degree of Separation", label ="Appx" )
     savefig(fig2, "degree_of_seperation.png");
     
end

function calc_weights_dist(g::SimpleWeightedGraph{Int64,Int64})::Tuple{SimpleWeightedGraph{Int64,Int64},Array{Float64}}
    cc = connected_components(g)
    lcc_index = argmax(length.(cc))
    sg = induced_subgraph(g, cc[lcc_index])
    savegraph("icalp_by_year_weighted/cc.lg" ,sg[1])
    g = loadgraph("icalp_by_year_weighted/cc.lg",  SWGFormat())
    dist_matrix = Array{Float64}(undef,nv(g), nv(g))
    for i in 1:nv(g)
        for j in 1:nv(g)
            if get_weight(g,i,j) == 0
                dist_matrix[i,j] = 0
            else
                dist_matrix[i,j] = get_weight(g,i,j)
            end
        end
    end
    return g, dist_matrix
end


function apx_closeness(graph::String, k::Int64)::Array{Float64}
    g::SimpleWeightedGraph{Int64,Int64} = loadgraph("icalp_by_year_weighted/"* graph, SWGFormat())
    cc = connected_components(g)
    lcc_index = argmax(length.(cc))
    sg = induced_subgraph_weighted(g, cc[lcc_index])
    savegraph("icalp_by_year_weighted/" * "cc" * graph,sg[1])
    g = loadgraph("icalp_by_year_weighted/" * "cc" * graph,  SWGFormat())
    farness::Array{Float64} = zeros(Float64, nv(g))
    for _ in 1:k
        farness = farness + gdistances(g, rand(1:nv(g)))
    end
    return (k * (nv(g) - 1)) ./ (nv(g) .* farness)
end

function prunedBFS(g::SimpleWeightedGraph{Int64,Int64}, source::Int64, topk::Float64)
    visited::Array{Bool} = falses(nv(g))
    cur_level::Array{Int64}, next_level::Array{Int64} = Vector(), Vector()
    visited[source] = true
    push!(cur_level, source)
    nd::Int64, farness::Int64, d::Int64 = 1, 0, 0
    while !isempty(cur_level)
        d, l_next_d::Int64 = d + 1, 0
        for v::Int64 in cur_level
            for i::Int64 in outneighbors(g, v)
                if !visited[i]
                    push!(next_level, i)
                    nd, farness = nd + 1, farness + d
                    l_next_d = l_next_d + degree(g, i) - 1
                    visited[i] = true
                end
            end
        end
        if (topk >= (nv(g) - 1) / farness)
            return 0
        end
        empty!(cur_level)
        cur_level, next_level = next_level, cur_level
    end
    return (nv(g) - 1) / farness
end

function induced_subgraph_weighted(g::SimpleWeightedGraph{Int64,Int64}, vlist::Array{Int64})
    allunique(vlist) || throw(ArgumentError("Vertices in subgraph list must be unique"))
    h = length(vlist)
    newvid = Dict{Integer,Integer}()
    vmap = Vector{Integer}(undef, length(vlist))
    for (i, v) in enumerate(vlist)
        newvid[v] = Int64(i)
        vmap[i] = v
    end
    vset = Set(vlist)
    for s in vlist
        for d in outneighbors(g, s)
            if d in vset && has_edge(g, s, d)
                newe = Edge(newvid[s], newvid[d])
                add_edge!(h, newe)
            end
        end
    end
    return h, vmap
end


function top_closeness(graph::String)::Tuple{Int64,Float64}
    g::SimpleWeightedGraph{Int64,Int64} = loadgraph("icalp_by_year_weighted/" * graph, SWGFormat())
    cc = connected_components(g)
    lcc_index = argmax(length.(cc))
    _, vmap = induced_subgraph1(g, cc[lcc_index])
    sg = induced_subgraph(g, cc[lcc_index])
    savegraph("icalp_by_year_weighted/cc" * graph, sg[1])
    g = loadgraph("icalp_by_year_weighted/cc" * graph,  SWGFormat())
    
    top_node::Int64, top_kappa::Float64 = 0, 0.0
    d::Array{Int64} = sortperm(degree(g), rev = true)
    for v in 1:nv(g)
        kappa_v::Float64 = prunedBFS(g, d[v], top_kappa)
        if (kappa_v > 0)
            top_node, top_kappa = d[v], kappa_v
        end
    end
    return vmap[top_node], top_kappa
end

function closeness(graph::String)::Array{Float64}
    g::SimpleWeightedGraph{Int64,Int64} = loadgraph("icalp_by_year_weighted/" * graph, SWGFormat())
    centrality = closeness_centrality(calc_weights_dist(g)[1], calc_weights_dist(g)[2])
    return centrality
end

function find_k_max_centrality(graph::String, k::Int64)
    s::Array{Float64} = closeness(graph)
    max = findmax(s)
    t = argmax(s)
    a = sortperm(s, rev=true)
    for i in 1:k
        print(collect(zip(a, s[a]))[i], "\n")
    end
end
