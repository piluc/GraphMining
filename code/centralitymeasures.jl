
function correlations(graph::String)::Array{Array{Float64}}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    d::Array{Float64} = degree_centrality(g)
    e::Array{Float64} = 1 ./ eccentricity(g)
    c::Array{Float64} = closeness_centrality(g)
    b::Array{Float64} = betweenness_centrality(g)
    return [[cor(d, e), cor(d, c), cor(d, b)], [cor(e, c), cor(e, b)], [cor(c, b)]]
end

function apx_closeness(graph::String, k::Int64)::Array{Float64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    farness::Array{Float64} = zeros(Float64, nv(g))
    for _ in 1:k
        farness = farness + gdistances(g, rand(1:nv(g)))
    end
    return (k * (nv(g) - 1)) ./ (nv(g) .* farness)
end

function florence_top_apx_closeness_three_nodes()::Nothing
    g::SimpleGraph{Int64} = loadgraph("graphs/florence.lg", "graph")
    isMax = zeros(Int64, nv(g))
    for u in 1:nv(g)
        du = gdistances(g, u)
        for v in 1:nv(g)
            dv = gdistances(g, v)
            for w in 1:nv(g)
                dw = gdistances(g, w)
                farness = du + dv + dw
                m = argmax((3 * (nv(g) - 1)) ./ (nv(g) .* farness))
                isMax[m] = isMax[m] + 1
            end
        end
    end
    println(isMax)
end

function check_top_apx_closeness(graph::String, kfactor::Int64, top_node::Int64, pos::Int64, ne::Int64)::Int64
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    k::Int64 = kfactor * trunc(log2(nv(g)))
    println(k)
    ns::Int64 = 0
    for _ in 1:ne
        kappa = apx_closeness(graph, k)
        m = partialsortperm(kappa, 1:pos, rev = true)
        if top_node in m
            ns = ns + 1
        end
    end
    return ns
end
# g = loadgraph("/Users/piluc/icloud/books/ars/grafi/connectome.lg", "graph")
# function top_apx_closeness(g, topnode, kfactor, ne, pos)
#     ns = 0
#     k = kfactor * trunc(log2(nv(g)))
#     println("k: ", k)
#     for e in 1:ne
#         farness = zeros(Float64, nv(g))
#         for e in 1:k
#             x = rand(1:nv(g))
#             d = gdistances(g, x)
#             farness = farness + d
#         end
#         kappa = zeros(Float64, nv(g))
#         for u in 1:nv(g)
#             kappa[u] = (k * (nv(g) - 1)) / (nv(g) * farness[u])
#         end
#         m = partialsortperm(kappa, 1:pos, rev = true)
#         if topnode in m
#             ns = ns + 1
#         end
#     end
#     return ns
# end

# function prunedBFS(g, source, topk)
#     n = nv(g)
#     visited = falses(n)
#     cur_level = Vector()
#     next_level = Vector()
#     visited[source] = true
#     push!(cur_level, source)
#     nd = 1
#     farness = 0
#     d = 0
#     while !isempty(cur_level)
#         d = d + 1
#         l_next_d = 0
#         for v in cur_level
#             for i in outneighbors(g, v)
#                 if !visited[i]
#                     push!(next_level, i)
#                     nd = nd + 1
#                     farness = farness + d
#                     l_next_d = l_next_d + degree(g, i) - 1
#                     visited[i] = true
#                 end
#             end
#         end
#         if (topk >= (n - 1) / farness)
#             return 0
#         end
#         empty!(cur_level)
#         cur_level, next_level = next_level, cur_level
#     end
#     return (n - 1) / farness
# end

# function top_closeness(g)
#     top_node = 0
#     top_kappa = 0
#     d = partialsortperm(degree(g), 1:nv(g), rev = true)
#     for v in 1:nv(g)
#         kappa_v = prunedBFS(g, d[v], top_kappa)
#         if (kappa_v > 0)
#             top_node = d[v]
#             top_kappa = kappa_v
#         end
#     end
#     return top_node, top_kappa
# end