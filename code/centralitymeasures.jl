using LightGraphs
using Statistics

# g = loadgraph("/Users/piluc/icloud/books/ars/grafi/florence.lg", "graph")
# d = degree_centrality(g)
# x = eccentricity(g)
# e = zeros(Float64, nv(g))
# for u in 1:nv(g)
#     e[u] = 1 / x[u]
# end
# c = closeness_centrality(g)
# b = betweenness_centrality(g)

# r_de = cor(d, e)
# r_dc = cor(d, c)
# r_db = cor(d, b)
# r_ec = cor(e, c)
# r_eb = cor(e, b)
# r_cb = cor(c, b)
# println(r_de," ",r_dc," ",r_db)
# println(r_ec," ",r_eb)
# println(r_cb)

# farness = zeros(Float64, nv(g))
# k = trunc(log2(nv(g)))
# println("k: ",k)
# for e in 1:k
#     x = rand(1:nv(g))
#     println("x: ", x)
#     d = gdistances(g, x)
#     global farness = farness + d
# end
# kappa = zeros(Float64, nv(g))
# for u in 1:nv(g)
#     global kappa[u] = (k * (nv(g) - 1)) / (nv(g) * farness[u])
#     println(kappa[u])
# end

# isMax = zeros(Int64, nv(g))
# for u in 1:nv(g)
#     du = gdistances(g, u)
#     for v in 1:nv(g)
#         dv = gdistances(g, v)
#         for w in 1:nv(g)
#             dw = gdistances(g, w)
#             farness = du + dv + dw
#             kappa = zeros(Float64, nv(g))
#             for u in 1:nv(g)
#                 global kappa[u] = (3 * (nv(g) - 1)) / (nv(g) * farness[u])
#             end
#             m = argmax(kappa)
#             global isMax[m] = isMax[m] + 1
#         end
#     end
# end
# println(isMax)

# g = loadgraph("/Users/piluc/icloud/books/ars/grafi/connectome.lg", "graph")
function top_apx_closeness(g, topnode, kfactor, ne, pos)
    ns = 0
    k = kfactor * trunc(log2(nv(g)))
    println("k: ", k)
    for e in 1:ne
        farness = zeros(Float64, nv(g))
        for e in 1:k
            x = rand(1:nv(g))
            d = gdistances(g, x)
            farness = farness + d
        end
        kappa = zeros(Float64, nv(g))
        for u in 1:nv(g)
            kappa[u] = (k * (nv(g) - 1)) / (nv(g) * farness[u])
        end
        m = partialsortperm(kappa, 1:pos, rev=true)
        if topnode in m
            ns = ns + 1
        end
    end
    return ns
end

function prunedBFS(g, source, topk)
    n = nv(g)
    visited = falses(n)
    cur_level = Vector()
    next_level = Vector()
    visited[source] = true
    push!(cur_level, source)
    nd = 1
    farness = 0
    d = 0
    while !isempty(cur_level)
        d = d + 1
        l_next_d = 0
        for v in cur_level
            for i in outneighbors(g, v)
                if !visited[i]
                    push!(next_level, i)
                    nd = nd + 1
                    farness = farness + d
                    l_next_d = l_next_d + degree(g, i) - 1
                    visited[i] = true
                end
            end
        end
        if (topk >= (n - 1) / farness)
            return 0
        end
        empty!(cur_level)
        cur_level, next_level = next_level, cur_level
    end
    return (n - 1) / farness
end

function top_closeness(g)
    top_node = 0
    top_kappa = 0
    d = partialsortperm(degree(g), 1:nv(g), rev=true)
    for v in 1:nv(g)
        kappa_v = prunedBFS(g, d[v], top_kappa)
        if (kappa_v > 0)
            top_node = d[v]
            top_kappa = kappa_v
        end
    end
    return top_node, top_kappa
end