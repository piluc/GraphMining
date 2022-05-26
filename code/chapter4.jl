
# Section 4.1.1
function correlations(graph::String)::Array{Array{Float64}}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    d::Array{Float64} = degree_centrality(g)
    e::Array{Float64} = 1 ./ eccentricity(g)
    c::Array{Float64} = closeness_centrality(g)
    b::Array{Float64} = betweenness_centrality(g)
    return [[cor(d, e), cor(d, c), cor(d, b)], [cor(e, c), cor(e, b)], [cor(c, b)]]
end

# Section 4.3.2
function apx_closeness(graph::String, k::Int64)::Array{Float64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    farness::Array{Float64} = zeros(Float64, nv(g))
    for _ in 1:k
        farness = farness + gdistances(g, rand(1:nv(g)))
    end
    return (k * (nv(g) - 1)) ./ (nv(g) .* farness)
end

# Section 4.3.3
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

# Section 4.3.3
function check_top_apx_closeness(graph::String, kfactor::Int64, top_node::Int64, pos::Int64, ne::Int64)::Int64
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    k::Int64 = kfactor * trunc(log2(nv(g)))
    ns::Int64 = 0
    for _ in 1:ne
        kappa = apx_closeness(graph, k)
        m = partialsortperm(kappa, 1:pos, rev=true)
        if top_node in m
            ns = ns + 1
        end
    end
    return ns
end

# Section 4.4
function prunedBFS(g::SimpleGraph{Int64}, source::Int64, topk::Float64)
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

# Section 4.4
function top_closeness(graph::String)::Tuple{Int64,Float64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    top_node::Int64, top_kappa::Float64 = 0, 0.0
    d::Array{Int64} = sortperm(degree(g), rev=true)
    for v in 1:nv(g)
        kappa_v::Float64 = prunedBFS(g, d[v], top_kappa)
        if (kappa_v > 0)
            top_node, top_kappa = d[v], kappa_v
        end
    end
    return top_node, top_kappa
end

# Section 4.4
function top_closeness_textbook(graph::String)::Tuple{Int64,Float64}
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    c = closeness_centrality(g)
    t = argmax(c)
    return t, c[t]
end