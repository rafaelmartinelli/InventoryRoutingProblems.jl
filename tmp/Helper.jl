function evalInventory(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}})
    V = 1:length(data.vertices)
    K = 1:data.num_vehicles
    H = 1:data.num_periods

    model = Model(Gurobi.Optimizer)

    @variable(model, s[H, v in V] >= data.vertices[v].inv_min)
    @variable(model, q[H, V, K] >= 0)

    @objective(model, Min, sum(data.vertices[v].inv_cost * s[t, v] for t in H, v in V))

    @constraint(model, [t in H, v in V; v > 1], s[t, v] == (t == 1 ? data.vertices[v].inv_init : s[t - 1, v]) + sum(q[t, v, k] for k in K) - data.vertices[v].demand)
    @constraint(model, [t in H], s[t, 1] == (t == 1 ? data.vertices[1].inv_init : s[t - 1, 1]) - sum(q[t, v, k] for v in V, k in K) + data.vertices[1].demand)
    @constraint(model, [t in H, k in K], sum(q[t, v, k] for v in V) <= data.capacity)
    @constraint(model, [t in H, v in V; v > 1], (t == 1 ? data.vertices[v].inv_init : s[t - 1, v]) + sum(q[t, v, k] for k in K) <= data.vertices[v].inv_max)
    @constraint(model, [t in H, v in V, k in K; !(v in sol[t][k])], q[t, v, k] == 0)

    optimize!(model)        
    return objective_value(model) + sum(vertex.inv_init * vertex.inv_cost for vertex in data.vertices), termination_status(model)
end

function calculateRouteCost(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}})
    route_cost = 0
    for t in 1:data.num_periods
        for k in 1:data.num_vehicles
            for v in 2:length(sol[t][k])
                route_cost += data.costs[sol[t][k][v - 1], sol[t][k][v]]
            end
        end
    end
    return route_cost
end