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

    if pos <= 1 || pos > length(route)
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

    if pos <= 1 || pos > length(route)
        return
    end

    insert.solution.route_cost += c[route[pos - 1], item] + c[item, route[pos]] -
                                  c[route[pos - 1], route[pos]]
    
    insert!(route, pos, item)
    insert.solution.inventory_cost = solve!(insert.inventory, insert.solution.routes)
    insert.solution.cost = insert.solution.route_cost + insert.solution.inventory_cost
end

function random!(insert::Insert)
    visited = Vector{Int64}()
    unvisited = Vector{Int64}()
    t = rand(1:insert.data.num_periods)
    k = rand(1:insert.data.num_vehicles)
 
    if length(insert.solution.routes[t][k]) < 3
        return false
    end

    for i in 1:length(solution.routes[t])
        visited = append!(visited, solution.routes[t][i])
    end

    visited = union(visited)

    for j in 1:length(insert.data.vertices)
        if (insert.data.vertices[j].id in visited) continue
        else 
            unvisited = append!(unvisited, insert.data.vertices[j].id)
        end
    end

    if length(unvisited) == 0
        return false
    end

    i = rand(1:length(unvisited))
    item = unvisited[i]

    pos = rand(2:length(insert.solution.routes[t][k]))
    
    args = InsertArgs(t, k, pos, item)
    if eval(insert, args) != Inf64
        move!(insert, args)
        deleteat!(unvisited, i)
        return true
    end
    return false
end

function localSearch!(insert::Insert)
    moved = false

    for t in 1:insert.data.num_periods
        visited = Vector{Int64}()
        unvisited = Vector{Int64}()

        for i in 1:length(solution.routes[t])
            visited = append!(visited, solution.routes[t][i])
        end

        visited = union(visited)

        for j in 1:length(insert.data.vertices)
            if (insert.data.vertices[j].id in visited) continue
            else 
                unvisited = append!(unvisited, insert.data.vertices[j].id)
            end
        end
        
            for k in 1:insert.data.num_vehicles
                for pos in 2:length(insert.solution.routes[t][k])
                    size = length(unvisited)
                    indice = 1
                    while (indice < size) 
                        args = InsertArgs(t, k, pos, unvisited[indice])
                        diff = eval(insert, args)
                        if diff < -EPS
                            move!(insert, args)
                            deleteat!(unvisited, indice)
                            size = length(unvisited)
                            moved = true
                        end
                        indice += 1
                    end
                end
            end
    end
    return moved
end
