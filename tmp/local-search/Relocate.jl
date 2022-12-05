mutable struct Relocate <: Neighborhood
    data::InventoryRoutingProblem
    inventory::Inventory
    solution::Solution
end

struct RelocateArgs
    t1::Int64
    k1::Int64
    pos1::Int64
    t2::Int64
    k2::Int64
    pos2::Int64
end

function eval(relocate::Relocate, args::RelocateArgs)
    t1, k1, pos1 = args.t1, args.k1, args.pos1
    t2, k2, pos2 = args.t2, args.k2, args.pos2
    route1 = relocate.solution.routes[t1][k1]
    route2 = relocate.solution.routes[t2][k2]
    c = relocate.data.costs

    if pos1 <= 1 || pos1 >= length(route1) || pos2 <= 1 || pos2 > length(route2)
        return Inf64
    end

    if t1 == t2 && k1 == k2 && abs(pos1 - pos2) <= 1
        return Inf64
    end

    if t1 != t2 && relocate.solution.in_period[t2][route1[pos1]]
        return Inf64
    end

    route_diff = c[route1[pos1 - 1], route1[pos1 + 1]] +
                 c[route2[pos2 - 1], route1[pos1]] +
                 c[route1[pos1], route2[pos2]] -
                 c[route1[pos1 - 1], route1[pos1]] -
                 c[route1[pos1], route1[pos1 + 1]] -
                 c[route2[pos2 - 1], route2[pos2]]

    removed = route1[pos1]
    if t1 == t2 && pos1 > pos2
        deleteat!(route1, pos1)
        insert!(route2, pos2, removed)
    else
        insert!(route2, pos2, removed)
        deleteat!(route1, pos1)
    end
    inventory_cost = solve!(relocate.inventory, relocate.solution.routes)
    if t1 == t2 && pos1 > pos2
        deleteat!(route2, pos2)
        insert!(route1, pos1, removed)
    else
        insert!(route1, pos1, removed)
        deleteat!(route2, pos2)
    end
    inventory_diff = inventory_cost - relocate.solution.inventory_cost

    return route_diff + inventory_diff
end

function move!(relocate::Relocate, args::RelocateArgs)
    t1, k1, pos1 = args.t1, args.k1, args.pos1
    t2, k2, pos2 = args.t2, args.k2, args.pos2
    route1 = relocate.solution.routes[t1][k1]
    route2 = relocate.solution.routes[t2][k2]
    c = relocate.data.costs

    if pos1 <= 1 || pos1 >= length(route1) || pos2 <= 1 || pos2 > length(route2)
        return Inf64
    end

    if t1 == t2 && k1 == k2 && abs(pos1 - pos2) <= 1
        return Inf64
    end

    if t1 != t2 && relocate.solution.in_period[t2][route1[pos1]]
        return Inf64
    end

    relocate.solution.route_cost += c[route1[pos1 - 1], route1[pos1 + 1]] +
                 c[route2[pos2 - 1], route1[pos1]] +
                 c[route1[pos1], route2[pos2]] -
                 c[route1[pos1 - 1], route1[pos1]] -
                 c[route1[pos1], route1[pos1 + 1]] -
                 c[route2[pos2 - 1], route2[pos2]]

    removed = route1[pos1]
    relocate.solution.in_period[t1][removed] = false
    relocate.solution.in_period[t2][removed] = true

    if t1 == t2 && pos1 > pos2
        deleteat!(route1, pos1)
        insert!(route2, pos2, removed)
    else
        insert!(route2, pos2, removed)
        deleteat!(route1, pos1)
    end

    relocate.solution.inventory_cost = solve!(relocate.inventory, relocate.solution.routes)
    relocate.solution.cost = relocate.solution.route_cost + relocate.solution.inventory_cost
end

function random!(relocate::Relocate)
    t1 = rand(1:relocate.data.num_periods)
    k1 = rand(1:relocate.data.num_vehicles)
    t2 = rand(1:relocate.data.num_periods)
    k2 = rand(1:relocate.data.num_vehicles)

    if t1 == t2 && k1 == k2
        if length(relocate.solution.routes[t1][k1]) < 5
            return false
        end
    elseif length(relocate.solution.routes[t1][k1]) < 3 || length(relocate.solution.routes[t2][k2]) < 3
        return false
    end

    pos1 = rand(2:length(relocate.solution.routes[t1][k1]) - 1)
    pos2 = rand(2:length(relocate.solution.routes[t2][k2]))

    args = RelocateArgs(t1, k1, pos1, t2, k2, pos2)
    if eval(relocate, args) != Inf64
        move!(relocate, args)
        return true
    end
    return false
end

function localSearch!(relocate::Relocate)
    moved = false
    for t1 in 1:relocate.data.num_periods
        for k1 in 1:relocate.data.num_vehicles
            for t2 in 1:relocate.data.num_periods
                for k2 in 1:relocate.data.num_vehicles
                    for pos1 in 2:length(relocate.solution.routes[t1][k1]) - 1
                        for pos2 in 2:length(relocate.solution.routes[t2][k2])
                            args = RelocateArgs(t1, k1, pos1, t2, k2, pos2)
                            diff = eval(relocate, args)
                            if diff < -EPS
                                move!(relocate, args)
                                moved = true
                            end
                        end
                    end
                end
            end
        end
    end
    return moved
end
