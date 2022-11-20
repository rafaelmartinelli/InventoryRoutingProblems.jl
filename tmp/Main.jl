using InventoryRoutingProblems
using Printf

include("Constructive.jl")
include("Model.jl")
include("Helper.jl")
include("LocalSearch.jl")

using JuMP
using Gurobi
using HiGHS
using Random

max_pertubations = 10000
file = "S_abs1n5_2_H3"
data = loadIRP(file)
for vertex in data.vertices
    if vertex.inv_min > 0
        @warn("Minimum inventory > 0!")
    end
end
function runTest()
    println("=============== Constructive heuristic ===============\n")
    sol, left = constructive(data)
    inv_cost, feasible = evalInventory(data, sol)
    route_cost = calculateRouteCost(data, sol)

    total_cost = route_cost + inv_cost
    @printf("Total = %.2f (routing = %.2f, inventory = %.2f)\n\n", total_cost, route_cost, inv_cost)

    println("=============== Local Search ===============\n")
    for i=1:max_pertubations
        # sol, inv_cost, route_cost, total_cost= removeVerticeFromRoute(data, sol, total_cost, route_cost, inv_cost,i)
        # sol, inv_cost, route_cost, total_cost= swapTwoVerticesFromRoute(data, sol, total_cost, route_cost, inv_cost,i)
        sol, inv_cost, route_cost, total_cost= relocateTwoVerticesFromRoute(data, sol, total_cost, route_cost, inv_cost,i)
    end
    @printf("Total = %.2f (routing = %.2f, inventory = %.2f)\n", total_cost, route_cost, inv_cost)
end

runTest()
