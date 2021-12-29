function bowtie(g)
    group = zeros(Int64, nv(g))
    scc = strongly_connected_components(g)
    lscc_index = argmax(length.(scc))
    lscc = scc[lscc_index]
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

function group_out(g, u, group)
    visited = falses(nv(g))
    queue = Vector()
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

function group_in(g, u, group)
    rg = reverse(g)
    visited = falses(nv(rg))
    queue = Vector()
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

function group_tendril_in(g, group)
    visited = falses(nv(g))
    queue = Vector()
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

function group_tendril_out(g, group)
    rg = reverse(g)
    visited = falses(nv(rg))
    queue = Vector()
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

function one_experiment(n, alpha, p)
    g = grass_hop_rb(n, alpha)
    clean(g, p)
    cc = connected_components(g)
    lcc_index = argmax(length.(cc))
    lcc_g = induced_subgraph(g2, cc[lcc_index])[1]
    u = max_degree_node(lcc_g)
    diameter = ifub(lcc_g, u)
    return nv(lcc_g), diameter
end