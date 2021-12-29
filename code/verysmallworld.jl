using LightGraphs
# g = loadgraph("/Users/piluc/icloud/books/ars/grafi/dblp.lg", "graph")

# x = rand(1:nv(g))
# d = gdistances(g, x)
# lb = maximum(d)
# ub = 2*lb
# println("Limite inferiore: ",lb)
# println("Limite superiore: ",ub)

# x = rand(1:nv(g))
# d = gdistances(g, x)
# lb, y = findmax(d)
# d = gdistances(g, y)
# lb = max(lb,maximum(d))
# println("Lower bound: ",lb)

function max_degree_node(g)
    degree = degree_centrality(g, normalize=false)
    maxdegree, u = findmax(degree)
    return u
end

function ifub(g, u)
    d = gdistances(g, u)
    nbfs = 1
    i, lb = maximum(d), 0
    for u in 1:nv(g)
        if d[u] == i
            du  = gdistances(g, u)
            nbfs = nbfs + 1
            eccu = maximum(du)
            if lb < eccu
                lb = eccu
            end
        end
    end
    while lb <= 2 * (i - 1)
        i = i - 1
        for u in 1:nv(g)
            if d[u] == i
                du  = gdistances(g, u)
                nbfs = nbfs + 1
                eccu = maximum(du)
                if lb < eccu
                    lb = eccu
                end
            end
        end
    end
    return lb, nbfs
end
# println("Diameter ",lb," computed with ",nbfs," BFSs")

# g = loadgraph("/Users/piluc/Desktop/wgraph.lg", "graph")