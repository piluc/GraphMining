function t_distance(file_name::String, is_directed::Bool, source::Int64, num_nodes::Int64, t::Int64)
    distance = fill(typemax(Int64), num_nodes)
    distance[source] = t - 1
    for line in eachline(file_name)
        uvt = split(line, " ")
        u = parse(Int64, uvt[1])
        v = parse(Int64, uvt[2])
        te = parse(Int64, uvt[3])
        if (te >= t)
            if (te > distance[u] && te < distance[v])
                distance[v] = te
            end
            if (!is_directed)
                if (te > distance[v] && te < distance[u])
                    distance[u] = te
                end
            end
        end
    end
    return distance .- t .+ 1
end

function t_distance(file_name, is_directed, source, num_nodes, talpha, tomega)
    distance = fill(typemax(Int64), num_nodes)
    distance[source] = talpha - 1
    for line in eachline(file_name)
        uvt = split(line, " ")
        u = parse(Int64, uvt[1])
        v = parse(Int64, uvt[2])
        te = parse(Int64, uvt[3])
        if (te >= talpha && te <= tomega)
            if (te > distance[u] && te < distance[v])
                distance[v] = te
            end
            if (!is_directed)
                if (te > distance[v] && te < distance[u])
                    distance[u] = te
                end
            end
        end
    end
    return distance .- talpha .+ 1
end

function neighborhood_function(file_name, is_directed, num_nodes, talpha, tomega)
    reachable_pairs = 0
    for source in 1:num_nodes
        d = t_distance(file_name, is_directed, source, num_nodes, talpha, tomega)
        for u in 1:num_nodes
            if d[u] <= tomega - talpha + 1
                reachable_pairs = reachable_pairs + 1
            end
        end
    end
    return reachable_pairs / (num_nodes^2)
end

function reachability_diagram(file_name, is_directed, num_nodes, tmin, tmax, delta)
    talpha = tmin
    tomega = talpha + delta
    ni = 0
    while (tomega < tmax)
        rp = neighborhood_function(file_name, is_directed, num_nodes, talpha, tomega)
        println(ni, " ", rp)
        talpha = tomega
        tomega = talpha + delta
        ni = ni + 1
    end
end
