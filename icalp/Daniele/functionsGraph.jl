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

function distance_distribution(g::SimpleGraph{Int64})::Array{Float64}
    
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

function distance_distribution(g::SimpleGraph{Int64}, k::Int64)::Array{Float64}
    dd::Array{Int64} = zeros(Int64, nv(g) - 1)
    for _ in 1:k
        dd = dd + counts(gdistances(g, rand(1:nv(g))), 1:nv(g)-1)
    end
    return dd / (k * (nv(g) - 1))
end

function argmaxCC(cc::Vector{Vector{Int64}})
    a = 0
    mcc = 0
    for c in eachindex(cc)
        #println(size(c,1))
        if (size(cc[c],1) > size(mcc,1))
            mcc=cc[c]
            a=c
        end
    end
    return a
end

function calculateApproxDoS(g::SimpleGraph,factor::Int64)::Float64
    return degrees_of_separation( distance_distribution(g,ceil(Int64,factor*log(nv(g)))))
end

function loadWeightedGraph(p::String)::SimpleWeightedGraph
    f = open(p, "r")
    s=readline(f)
    nv=parse(Int64,split(s,",")[2])
    gw=SimpleWeightedGraph(nv)
    while ! eof(f) 
        # read a new / next line for every iteration          
        s = readline(f)       
        u,v,w=split(s,",")
        u=parse(Int64,u)
        v=parse(Int64,v)
        w=parse(Int64,w)
        add_edge!(gw,u,v,1/w)
     end
     return gw
end

function createMatrix3DWGraph(p::String,years::Vector{String},enriched::Bool)
    for i in years
        if (enriched==false)
            gw= loadWeightedGraph(p*i*".lg")
        else
            gw= loadWeightedGraph(p*"Enriched"*i*".lg")
        end
        
        gw_ccs=connected_components(gw)
        gw_mcc=gw_ccs[argmaxCC(gw_ccs)]
        gw_max_cc,gw_max_cc_map=induced_subgraph(gw,gw_mcc)
        nvertex=nv(gw_max_cc)
        matrix_dijkstra= zeros((nvertex,nvertex))
        for i in 1:nvertex
            ds=dijkstra_shortest_paths(gw_max_cc,i)
            for j in 1:nvertex
                matrix_dijkstra[i,j]=ds.dists[j]
                matrix_dijkstra[j,i]=ds.dists[j]
            end
        end
        np = pyimport("numpy")
        
        matrix_dijkstra_mvs=classical_mds(matrix_dijkstra,3)
        
        if (enriched==false)
            np.save(p*i*"_mvsMatrix.npy",matrix_dijkstra_mvs)
            np.save(p*i*"_distMatrix.npy",matrix_dijkstra)
        else
            np.save(p*"Enriched"*i*"_mvsMatrix.npy",matrix_dijkstra_mvs)
            np.save(p*"Enriched"*i*"_distMatrix.npy",matrix_dijkstra)

        end
    end
end

function cc_new_node_count(cc1::Vector{Int64},cc2::Vector{Int64})::Int64
    return size(cc1,1)-size(cc2,1)
end

function cc_new_node_ratio(cc1::Vector{Int64},cc2::Vector{Int64})::Float64
    return (size(cc1,1)-size(cc2,1))/size(cc2,1)
end

function cc_diff_components(cc1::Vector{Int64},cc2::Vector{Int64})::Bool
    return issubset(cc1,cc2)
end

function manyPlotsSimpleGraphs(p::String,years::Vector{String},enriched::Bool)
    arr_maxcomp=Vector{Vector{Int64}}()
    arr_sizemaxcomp=Vector{Int64}()
    arr_ratioSize=Vector{Float64}()
    arr_newNodes=Vector{Float64}()
    arr_dos=Vector{Float64}()
    arr_dos_approx=Vector{Float64}()
    arr_diameter=Vector{Int64}()
    for (i,j) in zip(years,1:48)
        if (enriched==false)
            g_temp = loadgraph(p*i*".lg")
        else
            g_temp = loadgraph(p*"Enriched"*i*".lg")
        end
        cc_temp = connected_components(g_temp)
        maxcomponent_temp=cc_temp[ argmaxCC(cc_temp) ]
        g_max_cc_temp,g_max_cc_map_temp = induced_subgraph(g_temp,maxcomponent_temp)
        push!(arr_maxcomp,maxcomponent_temp)
        append!(arr_sizemaxcomp,size(maxcomponent_temp,1))
        if (j>1)
            append!(arr_newNodes,cc_new_node_count(maxcomponent_temp,arr_maxcomp[j-1]) )
            append!(arr_ratioSize,cc_new_node_ratio(maxcomponent_temp,arr_maxcomp[j-1])*100 )
        else
            append!(arr_newNodes,size(maxcomponent_temp,1))
            append!(arr_ratioSize,100)
        end
        append!(arr_dos_approx,degrees_of_separation( distance_distribution(g_max_cc_temp,ceil(Int64,35*log(nv(g_max_cc_temp))))))
        append!(arr_dos,degrees_of_separation( distance_distribution(g_max_cc_temp)))
        append!(arr_diameter,diameter( g_max_cc_temp))
        
        # println("\nYear = ",i,"\nSize of Graph = ",nv(g_temp),"\nNumber of edges = ",ne(g_temp),"\nSize of maximum connected component = ",size(maxcomponent_temp,1),
        #     "\nDegree of separation = ",degrees_of_separation( distance_distribution(g_max_cc_temp)),
        #     "\nDegree of separation approx = ",degrees_of_separation( distance_distribution(g_max_cc_temp,ceil(Int64,35*log(nv(g_max_cc_temp))))))
        # if (j>1) 
        #     println("Same component? = ",cc_diff_components(arr_maxcomp[j-1],maxcomponent_temp))
        # end
    end

    plot(years,arr_dos,st=:path, title = "Degrees of separation", label = ["DoS" ], lw = 3, yticks = 0:0.5:12,xticks=(0:1:48,arr_years),xrotation = 90)
    plot!(years,arr_dos_approx,label = ["DoS_approx" ], lw = 3)
    if (enriched==false)
        png("./images/plotDegreeOfSeparation")
    else
        png("./images/plotDegreeOfSeparationEnriched")
    end

    plot(years,arr_sizemaxcomp,label = ["Size max component"], xticks=(0:1:48,arr_years),xrotation = 90,lw=3,yticks = 0:500:4000)
    if (enriched==false)
        png("./images/plotSize")
    else
        png("./images/plotSizeEnriched")
    end
    
    plot(years,arr_newNodes,label = ["New Authors"], xticks=(0:1:48,arr_years),xrotation = 90,lw=3, yticks = 0:10:250)
    if (enriched==false)
        png("./images/plotNewAuthors")
    else
        png("./images/plotNewAuthorsEnriched")
    end
    
    plot(years,arr_ratioSize,label = ["Percentage increment new authors"], xticks=(0:1:48,arr_years), xrotation = 90, lw=3,yticks = 0:10:100)
    if (enriched==false)
        png("./images/plotIncrementSize")
    else
        png("./images/plotIncrementSizeEnriched")
    end
    
    plot(years,arr_diameter,label = ["Diameter"], xticks=(0:1:48,arr_years), xrotation = 90, lw=3,yticks = 0:1:40)
    if (enriched==false)
        png("./images/plotDiameter")
    else
        png("./images/plotDiameterEnriched")
    end
    
end
