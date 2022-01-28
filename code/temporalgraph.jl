function t_distance(fn::String, isdir::Bool, s::Int64, n::Int64, t::Int64)::Array{Int64}
    distance::Array{Int64} = fill(typemax(Int64), n)
    distance[s] = t - 1
    for line in eachline(fn)
        uvt::Array{String} = split(line, " ")
        u::Int64 = parse(Int64, uvt[1])
        v::Int64 = parse(Int64, uvt[2])
        te::Int64 = parse(Int64, uvt[3])
        if (te >= t)
            if (te > distance[u] && te < distance[v])
                distance[v] = te
            end
            if (!isdir)
                if (te > distance[v] && te < distance[u])
                    distance[u] = te
                end
            end
        end
    end
    return distance .- t .+ 1
end

function t_distance(fn::String, isdir::Bool, s::Int64, n::Int64, ta::Int64, to::Int64)::Array{Int64}
    distance::Array{Int64} = fill(typemax(Int64), n)
    distance[s] = ta - 1
    for line in eachline(fn)
        uvt::Array{String} = split(line, " ")
        u::Int64 = parse(Int64, uvt[1])
        v::Int64 = parse(Int64, uvt[2])
        te::Int64 = parse(Int64, uvt[3])
        if (te >= ta && te <= to)
            if (te > distance[u] && te < distance[v])
                distance[v] = te
            end
            if (!isdir)
                if (te > distance[v] && te < distance[u])
                    distance[u] = te
                end
            end
        end
    end
    return distance .- ta .+ 1
end

function neighborhood_function(fn::String, isdir::Bool, n::Int64, ta::Int64, to::Int64)::Float64
    reachable_pairs::Int64 = 0
    for source in 1:n
        d::Array{Int64} = t_distance(fn, isdir, source, n, ta, to)
        for u in 1:n
            if d[u] <= to - ta + 1
                reachable_pairs = reachable_pairs + 1
            end
        end
    end
    return reachable_pairs / (n^2)
end

function reachability_diagram(fn::String, isdir::Bool, n::Int64, tm::Int64, tM::Int64, d::Int64)
    ta = tm
    to = ta + d
    ni = 0
    while (to < tM)
        rp = neighborhood_function(fn, isdir, n, ta, to)
        println(ni, " ", rp)
        ta = to
        to = ta + d
        ni = ni + 1
    end
end
