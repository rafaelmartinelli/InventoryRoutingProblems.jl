struct SwapInter
    data::InventoryRoutingProblem
    inventory::Inventory
    solution::Solution
end

struct SwapInterArgs
    t::Int64
    k1::Int64
    k2::Int64
    pos1::Int64
    pos2::Int64
end

function eval(swap::SwapInter, args::SwapArgs)
    t, k1, k2, pos1, pos2 = args.t, args.k1, args.k2, args.pos1, args.pos2
    route1 = swap.solution.routes[t][k1]
    route2 = swap.solution.routes[t][k2]
    c = swap.data.costs

    if pos1 <= 1 || pos1 >= length(route1) - 1
        return Inf64
    end

    if pos2 <= 1 || pos2 >= length(route2) - 1
        return Inf64
    end

    route_diff = c[route1[pos1 - 1], route2[pos2]] + c[route2[pos2], route1[pos1 + 1]] + c[route2[pos2 - 1], route1[pos1]] + c[route1[pos1], route2[pos2 + 1]] - c[route1[pos1 - 1], route[pos1]] - c[route1[pos1], route1[pos1 + 1]] - c[route2[pos2 - 1], route2[pos2]] - c[route2[pos2], route2[pos2 + 1]]
    route1[pos1], route2[pos2] = route2[pos2], route1[pos1]
    inventory_cost = solve!(swap.inventory, solution.routes)
    route1[pos1], route2[pos2] = route2[pos2], route1[pos1]
    inventory_diff = inventory_cost - solution.inventory_cost

    return route_diff + inventory_diff
end

function move(swap::SwapInter, args::SwapArgs)
    t, k1, k2, pos1, pos2 = args.t, args.k1, args.k2, args.pos1, args.pos2
    route1 = swap.solution.routes[t][k1]
    route2 = swap.solution.routes[t][k2]
    c = data.costs

    if pos1 <= 1 || pos1 >= length(route1) - 1
        return Inf64
    end

    if pos2 <= 1 || pos2 >= length(route2) - 1
        return Inf64
    end

    route1[pos1], route2[pos2] = route2[pos2], route1[pos1]
    swap.solution.route_cost += c[route1[pos1 - 1], route2[pos2]] + c[route2[pos2], route1[pos1 + 1]] + c[route2[pos2 - 1], route1[pos1]] + c[route1[pos1], route2[pos2 + 1]] - c[route1[pos1 - 1], route[pos1]] - c[route1[pos1], route1[pos1 + 1]] - c[route2[pos2 - 1], route2[pos2]] - c[route2[pos2], route2[pos2 + 1]]
    swap.solution.inventory_cost = solve!(swap.inventory, solution.routes)
    swap.solution.cost = swap.solution.route_cost + swap.solution.inventory_cost
end

function random(swap::SwapInter)
    t = rand(1:swap.data.num_periods)
    k1 = rand(1:swap.data.num_vehicles)
    k2 = rand(1:swap.data.num_vehicles)

    while (k1 == k2)
        k2 = rand(1:swap.data.num_vehicles)
    end
    
    pos1 = rand(2:length(swap.solution.routes[t][k1]) - 1)
    pos2 = rand(2:length(swap.solution.routes[t][k2]) - 1)

    args = SwapArgs(t, k1, k2, pos1, pos2)

    if eval(swap, args) != Inf64
        move(swap, args)
        return true
    end
    return false
end

function localSearch(swap::SwapInter)
    for t in 1:swap.data.num_periods
        for k1 in 1:swap.data.num_vehicles
            for k2 in (k1 + 1):swap.data.num_vehicles
                for pos1 in 2:length(swap.solution.routes[t][k1]) - 1
                    for pos2 in 2:length(swap.solution.routes[t][k2] - 1)
                        args = SwapArgs(t, k1, k2, pos1, pos2)
                        diff = eval(swap, args)
                    end

                    if diff < -EPS
                        move(swap, args)
                    end
                end
            end
        end
    end
end
