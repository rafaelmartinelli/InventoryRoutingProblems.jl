abstract type Constructive end

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
