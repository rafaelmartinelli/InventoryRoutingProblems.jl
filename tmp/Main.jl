using InventoryRoutingProblems
using Printf

include("Constructive.jl")
include("Model.jl")
include("Helper.jl")

using JuMP
using Gurobi
using Random

file = "S_abs1n5_2_H3"
data = loadIRP(file)
for vertex in data.vertices
    if vertex.inv_min > 0
        @warn("Minimum inventory > 0!")
    end
end

sol, left = constructive(data)
inv_cost, status = evalInventory(data, sol)
route_cost = calculateRouteCost(data, sol)

total_cost = route_cost + inv_cost
@printf("Total = %.2f (routing = %.2f, inventory = %.2f)\n", total_cost, route_cost, inv_cost)
