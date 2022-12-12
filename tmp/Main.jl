using InventoryRoutingProblems
using Printf
using JuMP
using HiGHS
using Random

EPS = 1e-5

include("Solution.jl")

include("inventory/Inventory.jl")
include("inventory/Formulation.jl")
include("inventory/MinCostFlow.jl")

include("constructive/Constructive.jl")
include("constructive/DemandLeft.jl")
include("constructive/AllVertices.jl")

include("local-search/Neighborhood.jl")
include("local-search/Shift.jl")
include("local-search/Swap.jl")
include("local-search/Relocate.jl")
include("local-search/Remove.jl")
include("local-search/Insert.jl")
include("local-search/LocalSearch.jl")

include("IteratedLocalSearch.jl")

Random.seed!(42)
file = "S_abs1n15_2_H6"

function main()
    println("Loading instance...")
    data = loadIRP(file)
    println(data)
    println()
    for vertex in data.vertices
        if vertex.inv_min > 0
            @warn("Minimum inventory > 0!")
        end
    end

    ils = IteratedLocalSearch(data)
    solution = solve!(ils)

    return solution
end

solution = main()
println(solution.routes)
