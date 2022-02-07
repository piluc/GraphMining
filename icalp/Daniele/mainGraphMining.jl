using Graphs
using StatsBase
using LinearAlgebra
using Plots
using SimpleWeightedGraphs
using MultivariateStats
using PyCall
using DelimitedFiles

include("functionsGraph.jl")


arr_years=[
            "1972","1974","1976","1977","1978","1979","1980","1981","1982","1983","1984","1985","1986","1987","1988","1989",
            "1990","1991","1992","1993","1994","1995","1996","1997","1998","1999","2000","2001","2002","2003","2004","2005",
            "2006","2007","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020","2021"
        ]
conferences=["icalp","focs","stoc"]
Dict_conf = Dict{String, Vector{String}}(
    "icalp" => ["./graphs/icalp/icalp","./graphs/icalpw/icalpw"],
    "focs" =>  ["./graphs/focs/focs","./graphs/focsw/focsw"],
    "stoc" =>  ["./graphs/stoc/stoc","./graphs/stocw/stocw"]
    )


for conf in conferences
    #createMatrix3DWGraph(Dict_conf[conf][2],arr_years,false)
    #println("Matrix3D "*conf*" created")
    #createMatrix3DWGraph(Dict_conf[conf][2],arr_years,true)
    #println("Matrix3D Enriched "*conf*" created")
    manyPlotsSimpleGraphs(Dict_conf[conf][1],arr_years,false,conf)
    println("Plot "*conf*" simple created")
    #manyPlotsSimpleGraphs(Dict_conf[conf][1],arr_years,true,conf)
    #println("Plot "*conf*" Enriched created")
end

println("Done")

