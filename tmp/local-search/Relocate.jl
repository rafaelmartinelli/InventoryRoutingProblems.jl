struct Relocate
    data::InventoryRoutingProblem
    formulation::Formulation
    solution::Solution
end

struct RelocateArgs
    t::Int64
    k::Int64
    pos::Int64
    t2::Int64
    k2::Int64
    pos2::Int64
end

function eval(relocate::Relocate, args::RelocateArgs)
    t, k, pos = args.t, args.k, args.pos
    t2, k2, pos2 = args.t2, args.k2, args.pos2
    route = relocate.solution.routes[t][k]
    route2 = relocate.solution.routes[t2][k2]
    c = relocate.data.costs

    if pos <= 1 || pos >= length(route[pos]) - 1 || pos2 <= 1 || pos2 >= length(route2[pos2]) - 1
        return Inf64
    end

    # 2 vehicles cannot visit the same customer in the same period,
    # nor can the same customer be visited twice on the same route.
    for v in 1:relocate.data.num_vehicles
        if pos in relocate.solution.routes[t2][v]
            return Inf64
        end
    end

    route_diff = c[route[pos - 1], route[pos + 1]] - c[route2[pos2 - 1], route[pos]] - c[route[pos], route2[pos2]]
    insert!(route2,pos2,route[pos])
    deleteat!(route,pos)
    inventory_cost = solve!(relocate.formulation, solution.routes)
    insert!(route,pos,route2[pos2])
    deleteat!(route2,pos2)
    inventory_diff = inventory_cost - solution.inventory_cost

    return route_diff + inventory_diff
end

function move(relocate::Relocate, args::RelocateArgs)
    t, k, pos = args.t, args.k, args.pos
    t2, k2, pos2 = args.t2, args.k2, args.pos2
    route = relocate.solution.routes[t][k]
    route2 = relocate.solution.routes[t2][k2]
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

    insert!(route2,pos2,route[pos])
    deleteat!(route,pos)
    relocate.solution.route_cost += c[route[pos - 1], route[pos + 1]] - c[route2[pos2 - 1], route[pos]] - c[route[pos], route2[pos2]]
    relocate.solution.inventory_cost = solve!(relocate.formulation, solution.routes)
    relocate.solution.cost = relocate.solution.route_cost + relocate.solution.inventory_cost
end

function random(relocate::Relocate)
    t = rand(1:relocate.data.num_periods)
    k = rand(1:relocate.data.num_vehicles)
    pos = rand(2:length(relocate.solution.routes[t][k]) - 2)

    t2 = rand(1:relocate.data.num_periods)
    k2 = rand(1:relocate.data.num_vehicles)
    pos2 = rand(2:length(relocate.solution.routes[t2][k2]) - 2)

    args = RelocateArgs(t, k, pos, t2, k2, pos2)

    if eval(relocate, args) != Inf64
        move(relocate, args)
        return true
    end
    return false
end

function localSearch(relocate::Relocate)
    for t in 1:relocate.data.num_periods
        for k in 1:relocate.data.num_vehicles
            for pos in 2:length(relocate.solution.routes[t][k]) - 2

                for t2 in 1:relocate.data.num_periods
                    if t2 != t
                        for k2 in 1:relocate.data.num_vehicles
                            for pos2 in 2:length(relocate.solution.routes[t][k]) - 2
                                args = RelocateArgs(t, k, pos, t2, k2, pos2)
                                diff = eval(relocate, args)
                
                                if diff < -EPS
                                    move(relocate, args)
                                end

                            end
                        end
                    end
                end

            end
        end
    end
end
