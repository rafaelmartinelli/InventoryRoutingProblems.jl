struct RelocateIntra
    data::InventoryRoutingProblem
    inventory::Inventory
    solution::Solution
end

struct RelocateArgs
    t::Int64
    k::Int64
    pos1::Int64
    pos2::Int64
end

function eval(relocate::RelocateIntra, args::RelocateArgs)
    t, k, pos1, pos2 = args.t, args.k, args.pos1, args.pos2
    route = relocate.solution.routes[t][k]
    c = relocate.data.costs

    if pos1 <= 1 || pos1 >= length(route) - 1
        return Inf64
    end

    if pos2 <= 1 || pos2 >= length(route) - 1
        return Inf64
    end

    route_diff = c[route[pos1 - 1], route[pos1 + 1]] + c[route[pos1], route[pos2 - 1]] + c[route[pos1], route[pos2]] - c[route[pos1 - 1], route[pos1]] - c[route[pos1], route[pos1 + 1]] - c[route[pos2 - 1], route[pos2]] 
    vertice = route[pos1]
    deleteat!(route, pos1)
    insert!(route, pos2, vertice)
    inventory_cost = solve!(relocate.inventory, solution.routes)
    deleteat!(route, pos2)
    insert!(route, pos1, vertice)
    inventory_diff = inventory_cost - solution.inventory_cost

    return route_diff + inventory_diff
end

function move(relocate::RelocateIntra, args::RelocateArgs)
    t, k, pos1, pos2 = args.t, args.k, args.pos1, args.pos2
    route = relocate.solution.routes[t][k]
    c = data.costs

    if pos1 <= 1 || pos1 >= length(route) - 1
        return Inf64
    end

    if pos2 <= 1 || pos2 >= length(route) - 1
        return Inf64
    end

    vertice = route[pos1]
    deleteat!(route, pos1)
    insert!(route, pos2, vertice)
    relocate.solution.route_cost += c[route[pos1 - 1], route[pos1 + 1]] + c[route[pos1], route[pos2 - 1]] + c[route[pos1], route[pos2]] - c[route[pos1 - 1], route[pos1]] - c[route[pos1], route[pos1 + 1]] - c[route[pos2 - 1], route[pos2]] 
    relocate.solution.inventory_cost = solve!(relocate.inventory, solution.routes)
    relocate.solution.cost = relocate.solution.route_cost + relocate.solution.inventory_cost
end

function random(relocate::RelocateIntra)
    t = rand(1:relocate.data.num_periods)
    k = rand(1:relocate.data.num_vehicles)
    pos1 = rand(2:length(relocate.solution.routes[t][k]) - 1)
    pos2 = rand(2:length(relocate.solution.routes[t][k]) - 1)

    while (pos1 == pos2)
        pos2 = rand(2:length(relocate.solution.routes[t][k]) - 1)
    end

    args = RelocateArgs(t, k, pos1, pos2)

    if eval(relocate, args) != Inf64
        move(relocate, args)
        return true
    end
    return false
end

function localSearch(relocate::RelocateIntra)
    for t in 1:relocate.data.num_periods
        for k in 1:relocate.data.num_vehicles
            for pos1 in 2:length(relocate.solution.routes[t][k]) - 3
                for pos2 in (pos1 + 2):length(relocate.solution.routes[t][k])
                    args = RelocateArgs(t, k, pos1, pos2)
                    diff = eval(relocate, args)

                if diff < -EPS
                    move(relocate, args)
                end
            end
        end
    end
end
