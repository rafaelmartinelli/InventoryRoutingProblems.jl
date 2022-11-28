struct Swap
    data::InventoryRoutingProblem
    inventory::Inventory
    solution::Solution
end

struct SwapArgs
    t1::Int64
    k1::Int64
    pos1::Int64
    t2::Int64
    k2::Int64
    pos2::Int64
end

function eval(swap::Swap, args::SwapArgs)
    t1, k1, pos1 = args.t1, args.k1, args.pos1
    t2, k2, pos2 = args.t2, args.k2, args.pos2
    route1 = swap.solution.routes[t1][k1]
    route2 = swap.solution.routes[t2][k2]
    c = swap.data.costs

    if pos1 <= 1 || pos1 >= length(route1) || pos2 <= 1 || pos2 >= length(route2)
        return Inf64
    end

    if t1 == t2 && k1 == k2 && pos2 <= pos1 + 1
        return Inf64
    end

    if route1[pos1] == route2[pos2]
        return 0
    end

    if t1 != t2 && route1[pos1] != route2[pos2] && (swap.solution.in_period[t1][route2[pos2]] || swap.solution.in_period[t2][route1[pos1]])
        return Inf64
    end

    route_diff = c[route1[pos1 - 1], route2[pos2]] + c[route2[pos2 - 1], route1[pos1]] +
                 c[route2[pos2], route1[pos1 + 1]] + c[route1[pos1], route2[pos2 + 1]] -
                 c[route1[pos1 - 1], route1[pos1]] - c[route2[pos2 - 1], route2[pos2]] -
                 c[route1[pos1], route1[pos1 + 1]] - c[route2[pos2], route2[pos2 + 1]]
    route1[pos1], route2[pos2] = route2[pos2], route1[pos1]
    inventory_cost = solve!(swap.inventory, swap.solution.routes)
    route1[pos1], route2[pos2] = route2[pos2], route1[pos1]
    inventory_diff = inventory_cost - swap.solution.inventory_cost

    return route_diff + inventory_diff
end

function move(swap::Swap, args::SwapArgs)
    t1, k1, pos1 = args.t1, args.k1, args.pos1
    t2, k2, pos2 = args.t2, args.k2, args.pos2
    route1 = swap.solution.routes[t1][k1]
    route2 = swap.solution.routes[t2][k2]
    c = swap.data.costs

    if pos1 <= 1 || pos1 >= length(route1) || pos2 <= 1 || pos2 >= length(route2)
        return
    end

    if t1 == t2 && k1 == k2 && pos2 <= pos1 + 1
        return
    end

    if route1[pos1] == route2[pos2]
        return
    end

    if t1 != t2 && route1[pos1] != route2[pos2] && (swap.solution.in_period[t1][route2[pos2]] || swap.solution.in_period[t2][route1[pos1]])
        return
    end

    if t1 != t2 && route1[pos1] != route2[pos2]
        swap.solution.in_period[t1][route1[pos1]] = false
        swap.solution.in_period[t2][route1[pos1]] = true
        swap.solution.in_period[t2][route2[pos2]] = false
        swap.solution.in_period[t1][route2[pos2]] = true
    end

    swap.solution.route_cost += c[route1[pos1 - 1], route2[pos2]] + c[route2[pos2 - 1], route1[pos1]] +
                                c[route2[pos2], route1[pos1 + 1]] + c[route1[pos1], route2[pos2 + 1]] -
                                c[route1[pos1 - 1], route1[pos1]] - c[route2[pos2 - 1], route2[pos2]] -
                                c[route1[pos1], route1[pos1 + 1]] - c[route2[pos2], route2[pos2 + 1]]
    route1[pos1], route2[pos2] = route2[pos2], route1[pos1]
    swap.solution.inventory_cost = solve!(swap.inventory, swap.solution.routes)
    swap.solution.cost = swap.solution.route_cost + swap.solution.inventory_cost
end

function random(swap::Swap)
    t1 = rand(1:swap.data.num_periods)
    k1 = rand(1:swap.data.num_vehicles)
    t2 = rand(1:swap.data.num_periods)
    k2 = rand(1:swap.data.num_vehicles)

    if t1 == t2 && k1 == k2
        if length(swap.solution.routes[t1][k1]) < 5
            return false
        end
        pos1 = rand(2:length(swap.solution.routes[t1][k1]) - 3)
        pos2 = rand((pos1 + 2):length(swap.solution.routes[t2][k2]) - 1)
    else
        if length(swap.solution.routes[t1][k1]) < 3 || length(swap.solution.routes[t2][k2]) < 3
            return false
        end
        pos1 = rand(2:length(swap.solution.routes[t1][k1]) - 1)
        pos2 = rand(2:length(swap.solution.routes[t2][k2]) - 1)
    end

    args = SwapArgs(t1, k1, pos1, t2, k2, pos2)
    println(args)

    if eval(swap, args) != Inf64
        move(swap, args)
        return true
    end
    return false
end

function localSearch(swap::Swap)
    for t1 in 1:swap.data.num_periods
        for k1 in 1:swap.data.num_vehicles
            for t2 in 1:swap.data.num_periods
                for k2 in 1:swap.data.num_vehicles
                    end1 = length(swap.solution.routes[t1][k1]) - (t1 == t2 && k1 == k2 ? 3 : 1)
                    for pos1 in 2:end1
                        start2 = (t1 == t2 && k1 == k2 ? pos1 : 0) + 2
                        for pos2 in start2:length(swap.solution.routes[t1][k1]) - 2
                            args = SwapArgs(t1, k1, pos1, t2, k2, pos2)
                            diff = eval(swap, args)            
                            if diff < -EPS
                                move(swap, args)
                            end
                        end
                    end
                end
            end
        end
    end
end
