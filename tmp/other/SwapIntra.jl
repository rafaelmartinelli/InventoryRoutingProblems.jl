struct SwapIntra
    data::InventoryRoutingProblem
    inventory::Inventory
    solution::Solution
end

struct SwapArgs
    t::Int64
    k::Int64
    pos1::Int64
    pos2::Int64
end

function eval(swap::SwapIntra, args::SwapArgs)
    t, k, pos1, pos2 = args.t, args.k, args.pos1, args.pos2
    route = swap.solution.routes[t][k]
    c = swap.data.costs

    if pos1 <= 1 || pos1 >= length(route) - 1
        return Inf64
    end

    if pos2 <= 1 || pos2 >= length(route) - 1
        return Inf64
    end

    route_diff = c[route[pos1 - 1], route[pos2]] + c[route[pos2], route[pos1 + 1]] + c[route[pos2 - 1], route[pos1]] + c[route[pos1], route[pos2 + 1]] - c[route[pos1 - 1], route[pos1]] - c[route[pos1], route[pos1 + 1]] - c[route[pos2 - 1], route[pos2]] - c[route[pos2], route[pos2 + 1]]
    route[pos1], route[pos2] = route[pos2], route[pos1]
    inventory_cost = solve!(swap.inventory, solution.routes)
    route[pos1], route[pos2] = route[pos2], route[pos1]
    inventory_diff = inventory_cost - solution.inventory_cost

    return route_diff + inventory_diff
end

function move(swap::SwapIntra, args::SwapArgs)
    t, k, pos1, pos2 = args.t, args.k, args.pos1, args.pos2
    route = swap.solution.routes[t][k]
    c = data.costs

    if pos1 <= 1 || pos1 >= length(route) - 1
        return Inf64
    end

    if pos2 <= 1 || pos2 >= length(route) - 1
        return Inf64
    end


    route[pos1], route[pos2] = route[pos2], route[pos1]
    swap.solution.route_cost += c[route[pos1 - 1], route[pos2]] + c[route[pos2], route[pos1 + 1]] + c[route[pos2 - 1], route[pos1]] + c[route[pos1], route[pos2 + 1]] - c[route[pos1 - 1], route[pos1]] - c[route[pos1], route[pos1 + 1]] - c[route[pos2 - 1], route[pos2]] - c[route[pos2], route[pos2 + 1]]
    swap.solution.inventory_cost = solve!(swap.inventory, solution.routes)
    swap.solution.cost = swap.solution.route_cost + swap.solution.inventory_cost
end

function random(swap::SwapIntra)
    t = rand(1:swap.data.num_periods)
    k = rand(1:swap.data.num_vehicles)
    pos1 = rand(2:length(swap.solution.routes[t][k]) - 1)
    pos2 = rand(2:length(swap.solution.routes[t][k]) - 1)

    while (pos1 == pos2)
        pos2 = rand(2:length(swap.solution.routes[t][k]) - 1)
    end

    args = SwapArgs(t, k, pos1, pos2)

    if eval(swap, args) != Inf64
        move(swap, args)
        return true
    end
    return false
end

function localSearch(swap::SwapIntra)
    for t in 1:swap.data.num_periods
        for k in 1:swap.data.num_vehicles
            for pos1 in 2:length(swap.solution.routes[t][k]) - 3
                for pos2 in (pos1 + 2):length(swap.solution.routes[t][k]) -1
                    args = SwapArgs(t, k, pos1, pos2)
                    diff = eval(swap, args)
                end

                if diff < -EPS
                    move(swap, args)
                end
            end
        end
    end
end
