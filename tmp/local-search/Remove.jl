mutable struct Remove <: Neighborhood
    data::InventoryRoutingProblem
    inventory::Inventory
    solution::Solution
end

struct RemoveArgs
    t::Int64
    k::Int64
    pos::Int64
end

function eval(remove::Remove, args::RemoveArgs)
    t, k, pos = args.t, args.k, args.pos
    route = remove.solution.routes[t][k]
    c = remove.data.costs

    if pos <= 1 || pos >= length(route) - 1
        return Inf64
    end

    route_diff = c[route[pos - 1], route[pos + 1]] -
                 c[route[pos - 1], route[pos]] - c[route[pos], route[pos + 1]]

    removed = route[pos]
    deleteat!(route, pos)
    inventory_cost = solve!(remove.inventory, remove.solution.routes)
    insert!(route, pos, removed)
    inventory_diff = inventory_cost - remove.solution.inventory_cost

    return route_diff + inventory_diff
end

function move!(remove::Remove, args::RemoveArgs)
    t, k, pos = args.t, args.k, args.pos
    route = remove.solution.routes[t][k]
    c = remove.data.costs

    if pos <= 1 || pos >= length(route) - 1
        return
    end

    remove.solution.route_cost += c[route[pos - 1], route[pos + 1]] -
                                  c[route[pos - 1], route[pos]] - c[route[pos], route[pos + 1]]
    deleteat!(route, pos)
    remove.solution.inventory_cost = solve!(remove.inventory, remove.solution.routes)
    remove.solution.cost = remove.solution.route_cost + remove.solution.inventory_cost
end

function random!(remove::Remove)
    t = rand(1:remove.data.num_periods)
    k = rand(1:remove.data.num_vehicles)

    if length(remove.solution.routes[t][k]) < 3
        return false
    end

    pos = rand(2:length(remove.solution.routes[t][k]) - 1)
    
    args = RemoveArgs(t, k, pos)
    if eval(remove, args) != Inf64
        move!(remove, args)
        return true
    end
    return false
end

function localSearch!(remove::Remove)
    moved = false
    for t in 1:remove.data.num_periods
        for k in 1:remove.data.num_vehicles
            for pos in 2:length(remove.solution.routes[t][k]) - 1
                args = RemoveArgs(t, k, pos)
                diff = eval(remove, args)
                if diff < -EPS
                    move!(remove, args)
                    moved = true
                end
            end
        end
    end
    return moved
end
