mutable struct Insert <: Neighborhood
    data::InventoryRoutingProblem
    inventory::Inventory
    solution::Solution
end

struct InsertArgs
    t::Int64
    k::Int64
    pos::Int64
    item::Int64
end

function eval(insert::Insert, args::InsertArgs)
    t, k, pos, item = args.t, args.k, args.pos, args.item
    route = insert.solution.routes[t][k]
    c = insert.data.costs

    if pos <= 1 || pos > length(route) || insert.solution.in_period[t][item]
        return Inf64
    end

    route_diff = c[route[pos - 1], item] + c[item, route[pos]] -
                 c[route[pos - 1], route[pos]]
    
    insert!(route, pos, item)
    inventory_cost = solve!(insert.inventory, insert.solution.routes)
    deleteat!(route, pos)
    inventory_diff = inventory_cost - insert.solution.inventory_cost

    return route_diff + inventory_diff
end

function move!(insert::Insert, args::InsertArgs)
    t, k, pos, item = args.t, args.k, args.pos, args.item
    route = insert.solution.routes[t][k]
    c = insert.data.costs

    if pos <= 1 || pos > length(route) || insert.solution.in_period[t][item]
        return
    end

    insert.solution.route_cost += c[route[pos - 1], item] + c[item, route[pos]] -
                                  c[route[pos - 1], route[pos]]
    
    insert!(route, pos, item)
    insert.solution.inventory_cost = solve!(insert.inventory, insert.solution.routes)
    insert.solution.cost = insert.solution.route_cost + insert.solution.inventory_cost
    insert.solution.in_period[t][item] = true
end

function random!(insert::Insert)
    t = rand(1:insert.data.num_periods)
    k = rand(1:insert.data.num_vehicles)
    pos = rand(2:length(insert.solution.routes[t][k]))

    unvisited = [ i for i in 2:length(insert.data.vertices) if !insert.solution.in_period[t][i] ]
    if length(unvisited) == 0
        return false
    end
    item = rand(unvisited)
    
    args = InsertArgs(t, k, pos, item)
    if eval(insert, args) != Inf64
        move!(insert, args)
        return true
    end
    return false
end

function localSearch!(insert::Insert)
    moved = false
    for t in 1:insert.data.num_periods
        unvisited = [ i for i in 2:length(insert.data.vertices) if !insert.solution.in_period[t][i] ]
        for k in 1:insert.data.num_vehicles
            for pos in 2:length(insert.solution.routes[t][k])
                for item in unvisited
                    args = InsertArgs(t, k, pos, item)
                    diff = eval(insert, args)
                    if diff < -EPS
                        move!(insert, args)
                        moved = true
                        filter!(x -> insert.solution.in_period[t][x], unvisited)
                    end
                end
            end
        end
    end
    return moved
end
