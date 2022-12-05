struct AllVertices <: Constructive
    data::InventoryRoutingProblem
    inventory::Inventory
end

function solve!(all_vertices::AllVertices)
    data = all_vertices.data
    routes = [ [ Int64[] for _ in 1:data.num_vehicles ] for _ in 1:data.num_periods ]

    for t in 1:data.num_periods
        for k in 1:data.num_vehicles
            push!(routes[t][k], 1)
        end

        k = 1
        vertices = shuffle(2:length(data.vertices))
        for vertex in vertices
            push!(routes[t][k], vertex)
            k = k % data.num_vehicles + 1
        end

        for k in 1:data.num_vehicles
            push!(routes[t][k], 1)
        end
    end

    route_cost = calculateRouteCost(data, routes)
    inventory_cost = solve!(all_vertices.inventory, routes)
    in_period = [ BitVector([ 1 for _ in 1:length(data.vertices) ]) for _ in 1:data.num_periods ]
    return Solution(routes, route_cost + inventory_cost, route_cost, inventory_cost, in_period)
end
