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
        if (enriched==false)
            writedlm(p*i*"map.txt",gw_max_cc_map)
        else
            writedlm(p*"Enriched"*i*"map.txt",gw_max_cc_map)
        end
        
        
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

function loadMatrixApplyMVS(p::String) 
    np = pyimport("numpy")
    matrix=np.load(p*".npy")
    matrix_mvs_3d=classical_mds(matrix,3)
    np.save(p*"_mvsJulia3D.npy",matrix_mvs_3d)
    matrix_mvs_2d=classical_mds(matrix,2)
    np.save(p*"_mvsJulia2D.npy",matrix_mvs_2d)
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

function number_triangles(g::SimpleGraph{Int64})
    d::Array{Int64} = degree_centrality(g, normalize = false)
    c::Int64 = 0
    for u in 1:nv(g)
        for v in neighbors(g, u)
            if (d[v] > d[u] || (d[v] == d[u] && v > u))
                for w in neighbors(g, u)
                    if (d[w] > d[v] || (d[w] == d[v] && w > v))
                        if has_edge(g, v, w)
                            c = c + 1
                        end
                    end
                end
            end
        end
    end
    return c
end



function manyPlotsSimpleGraphs(p::String,years::Vector{String},enriched::Bool,conf::String)
    Dict_maxcomp = Dict{String, Vector{Int64}}()
    Dict_sizemaxcomp=Dict{String, Int64}()
    Dict_ratioSize=Dict{String,Float64}()
    Dict_ratioSizeGiantComponent=Dict{String,Float64}()
    Dict_newNodes=Dict{String,Float64}()
    Dict_dos=Dict{String,Float64}()
    Dict_dos_approx=Dict{String,Float64}()
    Dict_diameter=Dict{String,Int64}()
    Dict_cluster_coeff_g=Dict{String,Float64}()
    Dict_cluster_coeff_giant_comp=Dict{String,Float64}()
    for (i,j) in zip(years,1:48)
        if (enriched==false)
            g_temp = loadgraph(p*i*".lg")
        else
            g_temp = loadgraph(p*"Enriched"*i*".lg")
        end
        if nv(g_temp)==0
            Dict_maxcomp[i] = []
            Dict_sizemaxcomp[i]=0
            Dict_ratioSize[i]=0
            Dict_ratioSizeGiantComponent[i]=0
            Dict_newNodes[i]=0
            Dict_dos[i]=0
            Dict_dos_approx[i]=0
            Dict_diameter[i]=0
            Dict_cluster_coeff_g[i]=0
            Dict_cluster_coeff_giant_comp[i]=0
            continue
        end

        cc_temp = connected_components(g_temp)
        maxcomponent_temp=cc_temp[ argmaxCC(cc_temp) ]
        g_max_cc_temp,g_max_cc_map_temp = induced_subgraph(g_temp,maxcomponent_temp)
        if (enriched==false)
            outfile = p*i*"_map.txt"
        else
            outfile = p*"Entiched"*i*"_map.txt"
        end
        f = open(outfile, "w")
        for i in g_max_cc_map_temp
            println(f, i)
        end
        close(f)


        Dict_cluster_coeff_g[i]=number_triangles(g_temp) / binomial(nv(g_temp),3)
        Dict_cluster_coeff_giant_comp[i]=number_triangles(g_max_cc_temp)/ binomial(nv(g_max_cc_temp),3)

        Dict_maxcomp[i] = maxcomponent_temp
        Dict_sizemaxcomp[i]=size(maxcomponent_temp,1)

        Dict_ratioSizeGiantComponent[i]=size(maxcomponent_temp,1)/nv(g_temp)

        Dict_dos[i]=degrees_of_separation( distance_distribution(g_max_cc_temp))
        Dict_dos_approx[i]=degrees_of_separation( distance_distribution(g_max_cc_temp,ceil(Int64,35*log(nv(g_max_cc_temp)))))
        Dict_diameter[i]=diameter( g_max_cc_temp)

        
        if (j>1 &&  Dict_sizemaxcomp[years[j-1]]>0)
            Dict_newNodes[i]=cc_new_node_count(maxcomponent_temp,Dict_maxcomp[years[j-1]])
            Dict_ratioSize[i]=cc_new_node_ratio(maxcomponent_temp,Dict_maxcomp[years[j-1]])*100
        else
            Dict_newNodes[i]=size(maxcomponent_temp,1)
            Dict_ratioSize[i]=100
        end
        
    end

    plot(years,[ Dict_dos[i] for i in years],st=:path, title = "Degrees of separation "*conf, label = ["DoS" ], lw = 3, yticks = 0:0.5:12,xticks=(0:1:48,arr_years),xrotation = 90,legend=:bottomright)
    plot!(years,[ Dict_dos_approx[i] for i in years],label = ["DoS_approx" ], lw = 3)
    if (enriched==false)
        png("./images/"*conf*"/plotDegreeOfSeparation"*uppercasefirst(conf))
    else
        png("./images/"*conf*"/plotDegreeOfSeparationEnriched"*uppercasefirst(conf))
    end
    sizemaxcomp=findmax([Dict_sizemaxcomp[i] for i in years])[1]
    plot(years,[ Dict_sizemaxcomp[i] for i in years],label = ["Size max component "*conf], xticks=(0:1:48,arr_years),xrotation = 90,lw=3,yticks = 0:floor(sizemaxcomp/10):sizemaxcomp,legend=:topleft)
    if (enriched==false)
        png("./images/"*conf*"/plotSize"*uppercasefirst(conf))
    else
        png("./images/"*conf*"/plotSizeEnriched"*uppercasefirst(conf))
    end
    
    plot(years,[ Dict_newNodes[i] for i in years],label = ["New Authors "*conf], xticks=(0:1:48,arr_years),xrotation = 90,lw=3, yticks = 0:10:250,legend=:topleft)
    if (enriched==false)
        png("./images/"*conf*"/plotNewAuthors"*uppercasefirst(conf))
    else
        png("./images/"*conf*"/plotNewAuthorsEnriched"*uppercasefirst(conf))
    end
    
    plot(years,[ Dict_ratioSize[i] for i in years],label = ["Percentage increment new authors "*conf], xticks=(0:1:48,arr_years), xrotation = 90, lw=3,yticks = 0:10:500,legend=:topright)
    if (enriched==false)
        png("./images/"*conf*"/plotIncrementSize"*uppercasefirst(conf))
    else
        png("./images/"*conf*"/plotIncrementSizeEnriched"*uppercasefirst(conf))
    end
    
    plot(years,[ Dict_diameter[i] for i in years],label = ["Diameter "*conf], xticks=(0:1:48,arr_years), xrotation = 90, lw=3,yticks = 0:1:40,legend=:bottomright)
    if (enriched==false)
        png("./images/"*conf*"/plotDiameter"*uppercasefirst(conf))
    else
        png("./images/"*conf*"/plotDiameterEnriched"*uppercasefirst(conf))
    end

    plot(years,[ Dict_ratioSizeGiantComponent[i] for i in years],label = ["Size Giant Component / Size Graph "*conf], xticks=(0:1:48,arr_years), xrotation = 90, lw=3,yticks = 0:0.1:1,legend=:bottomright)
    if (enriched==false)
        png("./images/"*conf*"/plotRatioSizeGiantComponent"*uppercasefirst(conf))
    else
        png("./images/"*conf*"/plotRatioSizeGiantComponentEnriched"*uppercasefirst(conf))
    end



    plot(years[37:48],[ Dict_cluster_coeff_g[i] for i in years[37:48]],label = ["Clustering Coefficient Graph "*conf], lw=3,legend=:topright)
    if (enriched==false)
        png("./images/"*conf*"/plotClusteringCoefficientG"*uppercasefirst(conf))
    else
        png("./images/"*conf*"/plotClusteringCoefficientGEnriched"*uppercasefirst(conf))
    end

    plot(years[37:48],[ Dict_cluster_coeff_giant_comp[i] for i in years[37:48]],label = ["Clustering Coefficient Giant Component "*conf], lw=3,legend=:topright)
    if (enriched==false)
        png("./images/"*conf*"/plotClusteringCoefficientGiantComponent"*uppercasefirst(conf))
    else
        png("./images/"*conf*"/plotClusteringCoefficientGiantComponentEnriched"*uppercasefirst(conf))
    end
    
end
