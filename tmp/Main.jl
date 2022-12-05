using InventoryRoutingProblems
using Printf
# using JuMP
# using HiGHS
using Random

EPS = 1e-5

include("Solution.jl")

include("inventory/Inventory.jl")
# include("inventory/Formulation.jl")
include("inventory/MinCostFlow.jl")

include("Constructive.jl")
include("local-search/Shift.jl")
include("local-search/Swap.jl")
include("local-search/Relocate.jl")
include("local-search/Remove.jl")

Random.seed!(1)
max_pertubations = 10000
file = "S_abs1n15_2_H6"

function main()
    println("=============== Load instance ===============")
    data = loadIRP(file)
    println(data)
    for vertex in data.vertices
        if vertex.inv_min > 0
            @warn("Minimum inventory > 0!")
        end
    end

    # println("=============== Build inventory model ===============")
    # formulation = Formulation(data)
    # println("Built!")

    # println("=============== Constructive heuristic with model ===============")
    # constructive = Constructive(data, formulation)
    # @time solution = solve!(constructive)
    # @printf("Total = %.2f (routing = %.2f, inventory = %.2f)\n\n", solution.cost, solution.route_cost, solution.inventory_cost)

    println("=============== Build inventory graph ===============")
    flow = MinCostFlow(data)
    println("Built!")

    println("=============== Constructive heuristic with flow ===============")
    constructive = Constructive(data, flow)
    @time solution = solve!(constructive)
    @printf("Total = %.2f (routing = %.2f, inventory = %.2f)\n\n", solution.cost, solution.route_cost, solution.inventory_cost)

    println("=============== Shift Local Search ===============")
    shift = Shift(data, flow, solution)
    localSearch(shift)

    @printf("Total = %.2f (routing = %.2f, inventory = %.2f)\n\n", solution.cost, solution.route_cost, solution.inventory_cost)

    println("=============== Swap Local Search ===============")
    swap = Swap(data, flow, solution)
    localSearch(swap)

    @printf("Total = %.2f (routing = %.2f, inventory = %.2f)\n\n", solution.cost, solution.route_cost, solution.inventory_cost)

    println("=============== Relocate Local Search ===============")
    relocate = Relocate(data, flow, solution)
    localSearch(relocate)

    @printf("Total = %.2f (routing = %.2f, inventory = %.2f)\n\n", solution.cost, solution.route_cost, solution.inventory_cost)

    println("=============== Remove Local Search ===============")
    remove = Remove(data, flow, solution)
    localSearch(remove)

    @printf("Total = %.2f (routing = %.2f, inventory = %.2f)\n\n", solution.cost, solution.route_cost, solution.inventory_cost)

    # perc_init = 0.5
    # perc_final = 0.01
    # iterations = 10
    # mov_pertub = 5

    # ini_temp = (perc_init * solution.cost) / -log(perc_init);
    # end_temp = (perc_final * solution.cost) / -log(perc_final);
    # factor = (end_temp / ini_temp) ^ (1 / iterations);

    # temp = ini_temp

    # while temp > end_temp
    #     new_sol, new_route_cost = Pertub(data, sol, route_cost)
    #     new_sol, new_route_cost = localsearch(data, new_sol, new_route_cost)
        
    #     profit =  route_cost - best_sol_cost
        
    #     if profit < -EPS
    #         best_sol, best_route_cost = new_sol, new_route_cost 
    #     else
    #         prob = exp(-profit / temp)
    #         dice = rand()
            
    #         if (dice < prob)
    #             new_sol, new_route_cost = sol, route_cost 
    #         end          
    #     end
    #     temp = temp * factor
    # end

    # println("=============== Local Search ===============\n")
    # for i=1:max_pertubations
        # sol, inv_cost, route_cost, total_cost= removeVerticeFromRoute(data, sol, total_cost, route_cost, inv_cost,i)
        # sol, inv_cost, route_cost, total_cost= swapTwoVerticesFromRoute(data, sol, total_cost, route_cost, inv_cost,i)
    #     sol, inv_cost, route_cost, total_cost= relocateTwoVerticesFromRoute(data, sol, total_cost, route_cost, inv_cost,i)
    # end
    # @printf("Total = %.2f (routing = %.2f, inventory = %.2f)\n", total_cost, route_cost, inv_cost)

    return solution
end

solution = main()
