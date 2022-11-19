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

max_pertubations = 1000
file = "S_abs1n5_2_H3"
data = loadIRP(file)
for vertex in data.vertices
    if vertex.inv_min > 0
        @warn("Minimum inventory > 0!")
    end
end

println("=============== Constructive heuristic ===============\n")
sol, left = constructive(data)
inv_cost, feasible = evalInventory(data, sol)
route_cost = calculateRouteCost(data, sol)

total_cost = route_cost + inv_cost
@printf("Total = %.2f (routing = %.2f, inventory = %.2f)\n\n", total_cost, route_cost, inv_cost)

println("=============== Local Search ===============\n")
new_sol, new_inv_cost, new_route_cost, new_total_cost= removeVerticeFromRoute(data, sol, total_cost, max_pertubations)

@printf("Total = %.2f (routing = %.2f, inventory = %.2f)\n", new_total_cost, new_route_cost, new_inv_cost)
