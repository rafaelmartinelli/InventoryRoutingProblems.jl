struct Shift
    data::InventoryRoutingProblem
    inventory::Inventory
    solution::Solution
end

struct ShiftArgs
    t::Int64
    k::Int64
    pos::Int64
end

function eval(shift::Shift, args::ShiftArgs)
    t, k, pos = args.t, args.k, args.pos
    route = shift.solution.routes[t][k]
    c = shift.data.costs

    if pos <= 1 || pos >= length(route) - 1
        return Inf64
    end

    route_diff = c[route[pos - 1], route[pos + 1]] + c[route[pos], route[pos + 2]] -
                 c[route[pos - 1], route[pos]] - c[route[pos + 1], route[pos + 2]]
    route[pos], route[pos + 1] = route[pos + 1], route[pos]
    inventory_cost = solve!(shift.inventory, shift.solution.routes)
    route[pos], route[pos + 1] = route[pos + 1], route[pos]
    inventory_diff = inventory_cost - shift.solution.inventory_cost

    return route_diff + inventory_diff
end

function move(shift::Shift, args::ShiftArgs)
    t, k, pos = args.t, args.k, args.pos
    route = shift.solution.routes[t][k]
    c = shift.data.costs

    if pos <= 1 || pos >= length(route) - 1
        return
    end

    shift.solution.route_cost += c[route[pos - 1], route[pos + 1]] + c[route[pos], route[pos + 2]] -
                                 c[route[pos - 1], route[pos]] - c[route[pos + 1], route[pos + 2]]
    route[pos], route[pos + 1] = route[pos + 1], route[pos]
    shift.solution.inventory_cost = solve!(shift.inventory, shift.solution.routes)
    shift.solution.cost = shift.solution.route_cost + shift.solution.inventory_cost
end

function random(shift::Shift)
    t = rand(1:shift.data.num_periods)
    k = rand(1:shift.data.num_vehicles)

    if length(shift.solution.routes[t][k]) < 4
        return false
    end

    pos = rand(2:length(shift.solution.routes[t][k]) - 2)
    args = ShiftArgs(t, k, pos)

    if eval(shift, args) != Inf64
        move(shift, args)
        return true
    end
    return false
end

function localSearch(shift::Shift)
    for t in 1:shift.data.num_periods
        for k in 1:shift.data.num_vehicles
            for pos in 2:length(shift.solution.routes[t][k]) - 2
                args = ShiftArgs(t, k, pos)
                diff = eval(shift, args)

                if diff < -EPS
                    move(shift, args)
                end
            end
        end
    end
end
