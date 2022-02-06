using Graphs
using StatsBase
using LinearAlgebra
using Plots
using SimpleWeightedGraphs
using MultivariateStats
using PyCall
include("using Graphs.jl")


arr_years=[
            "1972","1974","1976","1977","1978","1979","1980","1981","1982","1983","1984","1985","1986","1987","1988","1989",
            "1990","1991","1992","1993","1994","1995","1996","1997","1998","1999","2000","2001","2002","2003","2004","2005",
            "2006","2007","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020","2021"
        ]
# createMatrix3DWGraph("./graphs/icalpw/icalpw",arr_years,false)
# createMatrix3DWGraph("./graphs/icalpw/icalpw",arr_years,true)

manyPlotsSimpleGraphs("./graphs/icalp/icalp",arr_years,false)
manyPlotsSimpleGraphs("./graphs/icalp/icalp",arr_years,true)
