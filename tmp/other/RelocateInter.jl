struct RelocateInter
    data::InventoryRoutingProblem
    inventory::Inventory
    solution::Solution
end

struct RelocateInterArgs
    t::Int64
    k1::Int64
    k2::Int64
    pos1::Int64
    pos2::Int64
end

function eval(relocate::RelocateInter, args::RelocateArgs)
    t, k1, k2, pos1, pos2 = args.t, args.k1, args.k2, args.pos1, args.pos2
    route1 = relocate.solution.routes[t][k1]
    route2 = relocate.solution.routes[t][k2]
    c = relocate.data.costs

    if pos1 <= 1 || pos1 >= length(route1) - 1
        return Inf64
    end

    if pos2 <= 1 || pos2 >= length(route2) - 1
        return Inf64
    end

    route_diff = c[route1[pos1 - 1], route1[pos1 + 1]] + c[route1[pos1], route2[pos2 - 1]] + c[route1[pos1], route2[pos2]] - c[route1[pos1 - 1], route1[pos1]] - c[route1[pos1], route1[pos1 + 1]] - c[route2[pos2 - 1], route2[pos2]] 
    vertice = route1[pos1]
    deleteat!(route1, pos1)
    insert!(route2, pos2, vertice)
    inventory_cost = solve!(relocate.inventory, solution.routes)
    deleteat!(route2, pos2)
    insert!(route1, pos1, vertice)
    inventory_diff = inventory_cost - solution.inventory_cost

    return route_diff + inventory_diff
end

function move(relocate::RelocateInter, args::RelocateArgs)
    t, k1, k2, pos1, pos2 = args.t, args.k1, args.k2, args.pos1, args.pos2
    route1 = relocate.solution.routes[t][k1]
    route2 = relocate.solution.routes[t][k2]
    c = data.costs

    if pos1 <= 1 || pos1 >= length(route1) - 1
        return Inf64
    end

    if pos2 <= 1 || pos2 >= length(route2) - 1
        return Inf64
    end

    vertice = route1[pos1]
    deleteat!(route1, pos1)
    insert!(route2, pos2, vertice)
    relocate.solution.route_cost += c[route1[pos1 - 1], route1[pos1 + 1]] + c[route1[pos1], route2[pos2 - 1]] + c[route1[pos1], route2[pos2]] - c[route1[pos1 - 1], route1[pos1]] - c[route1[pos1], route1[pos1 + 1]] - c[route2[pos2 - 1], route2[pos2]] 
    relocate.solution.inventory_cost = solve!(relocate.inventory, solution.routes)
    relocate.solution.cost = relocate.solution.route_cost + relocate.solution.inventory_cost
end

function random(relocate::RelocateInter)
    t = rand(1:relocate.data.num_periods)
    k1 = rand(1:relocate.data.num_vehicles)
    k2 = rand(1:relocate.data.num_vehicles)

    while (k1 == k2)
        k2 = rand(1:relocate.data.num_vehicles)
    end
    
    pos1 = rand(2:length(relocate.solution.routes[t][k1]) - 1)
    pos2 = rand(2:length(relocate.solution.routes[t][k2]) - 1)

    args = RelocateArgs(t, k1, k2, pos1, pos2)

    if eval(relocate, args) != Inf64
        move(relocate, args)
        return true
    end
    return false
end

function localSearch(relocate::RelocateInter)
    for t in 1:relocate.data.num_periods
        for k1 in 1:relocate.data.num_vehicles
            for k2 in (k1 + 1):relocate.data.num_vehicles
                for pos1 in 2:length(relocate.solution.routes[t][k1]) - 1
                    for pos2 in 2:length(relocate.solution.routes[t][k2] - 1)
                        args = RelocateArgs(t, k1, k2, pos1, pos2)
                        diff = eval(relocate, args)

                    if diff < -EPS
                        move(relocate, args)
                    end
                end
            end
        end
    end
end
