module InventoryRoutingProblems

using Distances

export InventoryRoutingProblem, IRPVertex, loadIRP

const data_path = joinpath(pkgdir(InventoryRoutingProblems), "data")
const EPS = 1e-5

include("Data.jl")
include("Loader.jl")

end
