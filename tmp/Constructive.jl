struct Constructive
    data::InventoryRoutingProblem
    inventory::Inventory
end

function solve!(constructive::Constructive)
    data = constructive.data
    routes = [ [ Int64[] for _ in 1:data.num_vehicles ] for _ in 1:data.num_periods ]

    left = [ vertex.inv_init for vertex in data.vertices ]
    for t in 1:data.num_periods
        for v in 1:length(data.vertices)
            if v == 1
                left[v] += data.vertices[v].demand
            else
                left[v] -= data.vertices[v].demand
            end
        end
        
        k = 1
        capacity = 0
        while k <= data.num_vehicles
            if length(routes[t][k]) == 0
                push!(routes[t][k], 1)
            end
            
            # vejo qual o melhor vertice para colocar na rota
            best = -1
            best_cost = typemax(Int64)
            for v in 2:length(data.vertices)
                if left[v] < 0 && capacity - left[v] <= data.capacity
                    if data.costs[routes[t][k][end], v] < best_cost
                        best = v
                        best_cost = data.costs[routes[t][k][end], v]
                    end
                end
            end

            # se não conseguir adicionar nenhum vertice eu adiciono o deposito (finalizo a rota)
            if best == -1
                push!(routes[t][k], 1)
                k += 1
                capacity = 0
                continue
            end

            # adiciono o vertice na rota 
            push!(routes[t][k], best)
            left[1] += left[best]
            capacity -= left[best]
            left[best] = 0
        end
    end

    route_cost = calculateRouteCost(data, routes)
    inventory_cost = solve!(constructive.inventory, routes)
    return Solution(routes, route_cost + inventory_cost, route_cost, inventory_cost)
end

function calculateRouteCost(data::InventoryRoutingProblem, routes::Vector{Vector{Vector{Int64}}})
    route_cost = 0
    for t in 1:data.num_periods
        for k in 1:data.num_vehicles
            for v in 2:length(routes[t][k])
                route_cost += data.costs[routes[t][k][v - 1], routes[t][k][v]]
            end
        end
    end
    return route_cost
end
