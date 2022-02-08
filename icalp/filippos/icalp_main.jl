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

function plot_degrees_of_separation(j::Int64)
    A = []
    B = [] 
    for i in years
        name = "icalp" * string(i) * ".lg";
        g = loadgraph("icalp_by_year/" * name, "graph")
        cc = connected_components(g)
        lcc_index = argmax(length.(cc)) 
        sg = induced_subgraph(g, cc[lcc_index])
        savegraph("icalpcc.lg",sg[1])
        icalpcc = loadgraph("icalpcc.lg", "graph")
        push!(A, degrees_of_separation("icalpcc.lg"))
        push!(B, degrees_of_separation(distance_distribution("icalpcc.lg",ceil(Int64, j * log(nv(icalpcc))))))
    end

     fig1 = plot(years,A, title = "Degree of Separation", label ="Exact" )
     fig2 = plot!(years,B, title = "Degree of Separation", label ="Appx" )
     savefig(fig2, "degree_of_seperation.png");
     
end

function calc_weights_dist(g::SimpleWeightedGraph{Int64,Float64})::Tuple{SimpleWeightedGraph{Int64,Float64},Array{Float64}}
    
    dist_matrix = Array{Float64}(undef,nv(g), nv(g))
    for i in 1:nv(g)
        for j in 1:nv(g)
                dist_matrix[i,j] = get_weight(g,i,j)
        end
    end
    return g, dist_matrix
end

function plots_lcc(weighted::Bool)
    lcc_array = Vector{Int64}()
    diameter_array = Vector{Int64}()
    for i in years
        if weighted == true
            graph = "icalp_weighted" * string(i) * ".lg"
            g = loadgraph("icalp_by_year_weighted/" * graph, SWGFormat())
        else
            graph = "icalp" * string(i) * ".lg"
            g = loadgraph("icalp_by_year/" * graph)
        end
        cc = connected_components(g)
        max_cc = cc[argmax(length.(cc))]
        g_sub , _ = induced_subgraph(g, max_cc)
        push!(diameter_array, diameter(g_sub)[1])
        push!(lcc_array,size(max_cc,1))
    end

    if weighted == true
        fig1 = plot(years,lcc_array,title = "Largest Connected Component - Weighted Graph", label ="size" )
        fig2 = plot(years,diameter_array,title = "Diameter - Weighted Graph", label ="size" )
        savefig(fig1, "lcc_weighted.png");
        savefig(fig2, "lcc_diameter_weighted.png");
    else
        fig1 = plot(years,lcc_array,title = "Largest Connected Component", label ="size" )
        fig2 = plot(years,diameter_array,title = "Diameter", label ="size" )
        savefig(fig1, "lcc_normal.png");
        savefig(fig2, "lcc_diameter_normal.png");
    end

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

function closeness(graph::String)
    g_weighted = loadgraph("icalp_by_year_weighted/" * graph, SWGFormat())
    cc = connected_components(g_weighted)
    lcc_index = argmax(length.(cc))
    #print("cc: ", cc)
    #print("cc[lcc_index]: ", cc[lcc_index])
    sg, vmap = induced_subgraph(g_weighted, cc[lcc_index])
    #print("vmap : ", vmap)
    savegraph("icalp_by_year_weighted/LCC_" * graph, sg)
    g = loadgraph("icalp_by_year_weighted/LCC_" * graph,  SWGFormat())
    #centrality = closeness_centrality(calc_weights_dist(g)[1], calc_weights_dist(g)[2])
    centrality = closeness_centrality(g, calc_weights_dist(g)[2])
    #sorted_centrality = sort(centrality, rev=true)
    #print("Sorted Centrality :", sorted_centrality)
    a = sortperm(centrality, rev=true)
    # print("a : ", a)
    # print("centrality[a] : ", centrality[a])
    print("\n")
    #print(vmap[centrality[a][1]])
    node = vmap[collect(zip(a, centrality[a]))[1][1]]
    centrality = collect(zip(a, centrality[a]))[1][2]
    print(node, "," ,centrality)

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

function betweenness_centrality_weighted(graph::String)
    g_weighted = loadgraph("icalp_by_year_weighted/" * graph, SWGFormat())
    cc = connected_components(g_weighted)
    lcc_index = argmax(length.(cc))
    sg, vmap = induced_subgraph(g_weighted, cc[lcc_index])
    savegraph("icalp_by_year_weighted/LCC_" * graph, sg)
    g = loadgraph("icalp_by_year_weighted/LCC_" * graph,  SWGFormat())
    bc = betweenness_centrality(g, calc_weights_dist(g)[2])
    a = sortperm(bc, rev=true)
    print("\n")
    node = vmap[collect(zip(a, bc[a]))[1][1]]
    centrality = collect(zip(a, bc[a]))[1][2]
    print(node, "," ,centrality)
end

    # for i in 1973:2022
    #     find_k_max_centrality("IICalp" * string(i) * "_weighted.lg", 1)
    # end
    # B = Array{Int64}(undef, 0)

    #B = Array{Float64}(undef,0)
    #push!(B, top_closeness("IICalp"*string(i)* "_weighted.lg")[1])
    #print("top closeness: " , top_closeness("IICalp"*string(i)* "_weighted.lg")[1], "\n")
    global years=["1972","1974","1976","1977","1978","1979","1980","1981","1982","1983","1984","1985","1986","1987","1988","1989",
            "1990","1991","1992","1993","1994","1995","1996","1997","1998","1999","2000","2001","2002","2003","2004","2005",
            "2006","2007","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020","2021"]
    #plot_degrees_of_separation(100)
    for i in years
    #     plots_lcc("IICalp" * string(i) * ".lg", false)
    #     print("\n")
    #plots_lcc(true)
    #plots_lcc(false)
          betweenness_centrality_weighted("icalp_weighted" * string(i) * ".lg")
          print("\n")
          print("closeness")
          print("\n")
          closeness("icalp_weighted" * string(i) * ".lg")
    end

 #print("B: ", B)

#print("apx closeness: " , apx_closeness("IICalp1976_weighted.lg", 2))

#print("apx_closeness: " , apx_closeness("IICalp1974_weighted.lg", 2))
#print(top_closeness1("IICalp1995.lg"))
# print("Not weighted: ", "\n")
# print(apx_closeness1(2))
# print("\n")

# print("Weighted: ", "\n")
# print(apx_closeness("icalp1991_weighted.lg", 2))
# print("\n")
#print(apx_closeness("sg1991_weighted.lg", 2))
#ifub("IICalp2022.lg",3)
#ds = dijkstra_shortest_paths(lcc_weighted, 21, dist_matrix)
#g = loadgraph("icalp_by_year/IICalp2022.lg", "graph")
#ds1 = dijkstra_shortest_paths(g, 2)