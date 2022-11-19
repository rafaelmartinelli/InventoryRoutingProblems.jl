include("Helper.jl")

function selectRandomElementToRemove(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}})
    t = rand(1:data.num_periods)
    k = rand(1:data.num_vehicles)
    v = rand(2:length(sol[t][k]))

    return t, k, v
end

function removeVerticeFromRoute(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}}, cost::Float64, max_pertubations::Int64)
    total_cost = cost
    route_cost = nothing
    inv_cost = nothing
    for i=1:max_pertubations
        t = nothing
        k = nothing
        v = nothing
        while true
            t, k, v = selectRandomElementToRemove(data, sol)
            if sol[t][k][v] != 1
                break
            end
        end
        # println("Selected element: sol[$t][$k][$v]")
        new_sol = deepcopy(sol)

        deleteat!(new_sol[t][k],v)
        new_inv_cost, feasible = evalInventory(data, new_sol)
        new_route_cost = calculateRouteCost(data, new_sol)
        new_total_cost = new_route_cost + new_inv_cost

        # println("New total cost: $new_total_cost (routing = $new_route_cost, inventory = $new_inv_cost)")

        if feasible && new_total_cost < cost
            println("Selected element on iteration $i: sol[$t][$k][$v]")
            println("New total cost: $new_total_cost (routing = $new_route_cost, inventory = $new_inv_cost)")
            println("New solution is feasible and better!\n")
            total_cost = new_total_cost
            sol = new_sol
            route_cost = new_route_cost
            inv_cost = new_inv_cost
        else
            # println("New solution is not feasible or worse!\n")
        end
        # println("Iteration $i: total cost = $total_cost")
    end
    return sol, inv_cost, route_cost, total_cost
end