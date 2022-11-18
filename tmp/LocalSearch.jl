include("Helper.jl")

function selectRandomElementToRemove(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}})
    t = rand(Int64, 1:data.num_periods)
    k = rand(Int64, 1:data.num_vehicles)
    v = rand(Int64, 2:length(sol[t][k]))

    return t,k,v
end

function checkFeasibility(status)
    inv_feasible = false
    if status == MOI.OPTIMAL
        inv_feasible = true
    elseif status == MOI.TIME_LIMIT && has_values(model)
        inv_feasible = true
    else
        inv_feasible = false
    end
    return inv_feasible
end

function remove(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}}, cost)

    while true
        t,k,v = selectRandomElementToRemove(sol, data)
        if sol[t][k][v] != 1
            break
        end
    end
    new_sol = deepcopy(sol)

    deleteat!(new_sol[t][k],v)
    inv_cost, status = evalInventory(data, sol)
    inv_feasible = checkFeasibility(status)
    

    if inv_feasible  &&

end