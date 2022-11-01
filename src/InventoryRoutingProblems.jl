module InventoryRoutingProblems

using p7zip_jll
using Distances

export InventoryRoutingProblem, IRPVertex, loadIRP

const data_path = joinpath(pkgdir(InventoryRoutingProblems), "data")
const EPS = 1e-5

include("Data.jl")
include("Util.jl")
include("Loader.jl")

end
