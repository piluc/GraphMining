using LightGraphs

function common_neighbors(g)
    s = fill(0.0, nv(g), nv(g))
    for u in 1:nv(g)
        for v in neighbors(g, u)
            for w in neighbors(g, u)
                if (w > v && !(w in neighbors(g, v)))
                    s[v,w] = length(findall(in(neighbors(g, v)), neighbors(g, w)))
                end
            end
        end
    end
    return s
end

function adamic_adar(g)
    s = fill(0.0, nv(g), nv(g))
    for w in 1:nv(g)
        for u in neighbors(g, w)
            for v in neighbors(g, w)
                if (v > u && !(v in neighbors(g, u)))
                    s[u,v] = s[u,v] + 1 / log(length(neighbors(g, w)))
                end
            end
        end
    end
    return s
end

function jaccard_index(g)
    s = fill(0.0, nv(g), nv(g))
    for w in 1:nv(g)
        for u in neighbors(g, w)
            for v in neighbors(g, w)
                if (v > u && !(v in neighbors(g, u)))
                    cap = length(findall(in(neighbors(g, u)), neighbors(g, v)))
                    cup = length(neighbors(g, u)) + length(neighbors(g, v)) - cap
                    s[u,v] = cap / cup
                end
            end
        end
    end
    return s
end

function negated_shortest_path(g)
    s = fill(0.0, nv(g), nv(g))
    for u in 1:nv(g)
        d = gdistances(g, u)
        for v in 1:nv(g)
            if (v > u && !(v in neighbors(g, u)) && d[v] < nv(g))
                s[u,v] = -d[v]
            end
        end
    end
    return s
end

function cosine_similarity(V, S, na, nf)
    for i in (1:na)
        for j in (1:na)
            totale = 0
            for k in (1:nf)
                if (V[i,k] != 0 || V[j,k] != 0)
                    totale = totale + 1
                end
                S[i,j] = S[i,j] + V[i,k] * V[j,k]
            end
            S[i,j] = S[i,j] / totale
        end
    end
end

function prediction(V, S, na, i, k)
    num = 0
    den = 0
    for j in (1:na)
        if (V[j,k] != 0)
            num = num + V[j,k] * S[i,j]
            den = den + abs(S[i,j])
        end
    end
    return num / den
end