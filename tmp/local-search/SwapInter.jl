struct Swap
    data::InventoryRoutingProblem
    formulation::Formulation
    solution::Solution
end

struct SwapArgs
    t::Int64
    k::Int64
    pos::Int64
    t2::Int64
    k2::Int64
    pos2::Int64
end

function eval(swap::Swap, args::SwapArgs)
    t, k, pos = args.t, args.k, args.pos
    t2, k2, pos2 = args.t2, args.k2, args.pos2
    route = swap.solution.routes[t][k]
    route2 = swap.solution.routes[t2][k2]
    c = swap.data.costs

    if pos <= 1 || pos >= length(route[pos]) - 1 || pos2 <= 1 || pos2 >= length(route2[pos2]) - 1
        return Inf64
    end

    # 2 vehicles cannot visit the same customer in the same period, 
    # nor can the same customer be visited twice on the same route.
    for v in 1:swap.data.num_vehicles
        if pos in swap.solution.routes[t2][v]
            return Inf64
        end
    end

    route_diff = c[route[pos - 1], route2[pos2]] + c[route2[pos2 - 1], route[pos]]
                + c[route2[pos2], route[pos + 1]] + c[route[pos], route2[pos2 + 1]]
                - c[route[pos - 1], route[pos]] - c[route2[pos2-1], route2[pos2]]
                - c[route[pos], route[pos + 1]] - c[route2[pos2], route2[pos2 + 1]]
    route[pos], route2[pos2] = route2[pos2], route[pos]
    inventory_cost = solve!(swap.formulation, solution.routes)
    route[pos], route2[pos2] = route2[pos2], route[pos]
    inventory_diff = inventory_cost - solution.inventory_cost

    return route_diff + inventory_diff
end

function move(swap::Swap, args::SwapArgs)
    t, k, pos = args.t, args.k, args.pos
    t2, k2, pos2 = args.t2, args.k2, args.pos2
    route = swap.solution.routes[t][k]
    route2 = swap.solution.routes[t2][k2]
    c = data.costs

    if pos <= 1 || pos >= length(route[pos]) - 1 || pos2 <= 1 || pos2 >= length(route2[pos2]) - 1
        return Inf64
    end

    # 2 vehicles cannot visit the same customer in the same period, 
    # nor can the same customer be visited twice on the same route.
    for v in 1:swap.data.num_vehicles
        if pos in swap.solution.routes[t2][v]
            return Inf64
        end
    end

    route[pos], route2[pos2] = route2[pos2], route[pos]
    swap.solution.route_cost += c[route[pos - 1], route2[pos2]] + c[route2[pos2 - 1], route[pos]]
                                + c[route2[pos2], route[pos + 1]] + c[route[pos], route2[pos2 + 1]]
                                - c[route[pos - 1], route[pos]] - c[route2[pos2-1], route2[pos2]]
                                - c[route[pos], route[pos + 1]] - c[route2[pos2], route2[pos2 + 1]]
    swap.solution.inventory_cost = solve!(swap.formulation, solution.routes)
    swap.solution.cost = swap.solution.route_cost + swap.solution.inventory_cost
end

function random(swap::Swap)
    t = rand(1:swap.data.num_periods)
    k = rand(1:swap.data.num_vehicles)
    pos = rand(2:length(swap.solution.routes[t][k]) - 2)

    t2 = rand(1:swap.data.num_periods)
    k2 = rand(1:swap.data.num_vehicles)
    pos2 = rand(2:length(swap.solution.routes[t2][k2]) - 2)

    args = SwapArgs(t, k, pos, t2, k2, pos2)

    if eval(swap, args) != Inf64
        move(swap, args)
        return true
    end
    return false
end

function localSearch(swap::Swap)
    for t in 1:swap.data.num_periods
        for k in 1:swap.data.num_vehicles
            for pos in 2:length(swap.solution.routes[t][k]) - 2

                for t2 in 1:swap.data.num_periods
                    if t2 != t
                        for k2 in 1:swap.data.num_vehicles
                            for pos2 in 2:length(swap.solution.routes[t][k]) - 2
                                args = SwapArgs(t, k, pos, t2, k2, pos2)
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
end
