include("Helper.jl")

function selectRandomElementToRemove(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}})
    t = rand(1:data.num_periods)
    k = rand(1:data.num_vehicles)
    v = rand(2:length(sol[t][k]))

    return t, k, v
end

function removeVerticeFromRoute(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}}, cost::Float64, route_cost::Int64, inv_cost::Float64, iter::Int64)
    total_cost = cost
    route_cost = route_cost
    inv_cost = inv_cost
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
        println("Selected element on iteration $iter: sol[$t][$k][$v]")
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
    return sol, inv_cost, route_cost, total_cost
end

function swapTwoVerticesFromRoute(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}}, cost::Float64, route_cost::Int64, inv_cost::Float64, iter::Int64)
    total_cost = cost
    route_cost = route_cost
    inv_cost = inv_cost
    t = nothing
    k = nothing
    v = nothing
    v2 = nothing
    while true
        t, k, v = selectRandomElementToRemove(data, sol)
        v2 = rand(2:length(sol[t][k]))
        if sol[t][k][v] != 1 && sol[t][k][v2] != 1
            break
        end
    end
    # println("Selected element: sol[$t][$k][$v]")
    new_sol = deepcopy(sol)

    temp = new_sol[t][k][v];
    new_sol[t][k][v] = new_sol[t][k][v2];
    new_sol[t][k][v2] = temp;

    new_inv_cost, feasible = evalInventory(data, new_sol)
    new_route_cost = calculateRouteCost(data, new_sol)
    new_total_cost = new_route_cost + new_inv_cost

    # println("New total cost: $new_total_cost (routing = $new_route_cost, inventory = $new_inv_cost)")

    if feasible && new_total_cost < cost
        println("Swap elements on iteration $iter: sol[$t][$k][$v] and sol[$t][$k][$v2]")
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
    return sol, inv_cost, route_cost, total_cost
end

function relocateTwoVerticesFromRoute(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}}, cost::Float64, route_cost::Int64, inv_cost::Float64, iter::Int64)
    total_cost = cost
    route_cost = route_cost
    inv_cost = inv_cost
    t = nothing
    k = nothing
    v = nothing
    t2 = nothing
    k2 = nothing
    v2 = nothing
    while true
        t, k, v = selectRandomElementToRemove(data, sol)
        t2, k2, v2 = selectRandomElementToRemove(data, sol)
        if sol[t][k][v] != 1 && v2 != 1
            break
        end
    end
    # println("Selected element: sol[$t][$k][$v]")
    new_sol = deepcopy(sol)

    insert!(new_sol[t2][k2],v2,new_sol[t][k][v])
    deleteat!(new_sol[t][k],v)

    new_inv_cost, feasible = evalInventory(data, new_sol)
    new_route_cost = calculateRouteCost(data, new_sol)
    new_total_cost = new_route_cost + new_inv_cost

    # println("New total cost: $new_total_cost (routing = $new_route_cost, inventory = $new_inv_cost)")

    if feasible && new_total_cost < cost
        println("Relocate elements on iteration $iter: sol[$t][$k][$v] removed and inserted before sol[$t2][$k2][$v2]")
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
    return sol, inv_cost, route_cost, total_cost
end
