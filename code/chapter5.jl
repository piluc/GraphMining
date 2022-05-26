# Section 5.2
function number_triangles(graph::String)
    g::SimpleGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    d::Array{Int64} = degree_centrality(g, normalize=false)
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

# Section 5.5.1
function bowtie(graph::String)::Array{Int64}
    g::SimpleDiGraph{Int64} = loadgraph("graphs/" * graph, "graph")
    group::Array{Int64} = zeros(Int64, nv(g))
    scc::Array{Array{Int64}} = strongly_connected_components(g)
    lscc_index::Int64 = argmax(length.(scc))
    lscc::Array{Int64} = scc[lscc_index]
    println("|SCC|=", length(lscc))
    for u in 1:length(lscc)
        group[lscc[u]] = 1
    end
    group_out(g, lscc[1], group)
    group_in(g, lscc[1], group)
    group_tendril_in(g, group)
    group_tendril_out(g, group)
    return group
end

# Section 5.5.1
function group_out(g::SimpleDiGraph{Int64}, u::Int64, group::Array{Int64})::Nothing
    visited::Array{Bool} = falses(nv(g))
    queue::Array{Int64} = Vector()
    visited[u] = true
    push!(queue, u)
    while !isempty(queue)
        u = pop!(queue)
        for v in outneighbors(g, u)
            if !visited[v]
                push!(queue, v)
                visited[v] = true
                if (group[v] == 0)
                    group[v] = 3
                end
            end
        end
    end
end

# Section 5.5.1
function group_in(g::SimpleDiGraph{Int64}, u::Int64, group::Array{Int64})::Nothing
    rg::SimpleDiGraph{Int64} = reverse(g)
    visited::Array{Bool} = falses(nv(rg))
    queue::Array{Int64} = Vector()
    visited[u] = true
    push!(queue, u)
    while !isempty(queue)
        u = pop!(queue)
        for v in outneighbors(rg, u)
            if !visited[v]
                push!(queue, v)
                visited[v] = true
                if (group[v] == 0)
                    group[v] = 2
                end
            end
        end
    end
end

# Section 5.5.1
function group_tendril_in(g::SimpleDiGraph{Int64}, group::Array{Int64})::Nothing
    visited::Array{Bool} = falses(nv(g))
    queue::Array{Int64} = Vector()
    for u in 1:nv(g)
        if (group[u] == 2)
            visited[u] = true
            push!(queue, u)
        end
        if (group[u] == 1)
            visited[u] = true
        end
    end
    while !isempty(queue)
        u = pop!(queue)
        for v in outneighbors(g, u)
            if !visited[v]
                push!(queue, v)
                visited[v] = true
                if (group[v] == 0)
                    group[v] = 4
                end
            end
        end
    end
end

# Section 5.5.1
function group_tendril_out(g::SimpleDiGraph{Int64}, group::Array{Int64})::Nothing
    rg::SimpleDiGraph{Int64} = reverse(g)
    visited::Array{Bool} = falses(nv(rg))
    queue::Array{Int64} = Vector()
    for u in 1:nv(rg)
        if (group[u] == 3)
            visited[u] = true
            push!(queue, u)
        end
        if (group[u] == 1)
            visited[u] = true
        end
    end
    while !isempty(queue)
        u = pop!(queue)
        for v in outneighbors(rg, u)
            if !visited[v]
                push!(queue, v)
                visited[v] = true
                if (group[v] == 0)
                    group[v] = 5
                end
                if (group[v] == 4)
                    group[v] = 6
                end
            end
        end
    end
end