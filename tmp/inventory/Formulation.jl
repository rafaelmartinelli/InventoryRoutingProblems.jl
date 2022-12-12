struct Formulation <: Inventory
    data::InventoryRoutingProblem
    model::JuMP.Model

    function Formulation(data::InventoryRoutingProblem)
        return new(data, buildModel(data))
    end
end

function buildModel(data::InventoryRoutingProblem)
    V = 1:length(data.vertices)
    K = 1:data.num_vehicles
    H = 1:data.num_periods
    PEN = 1000

    model = Model(HiGHS.Optimizer)
    set_silent(model)

    @variable(model, s[H, v in V] >= data.vertices[v].inv_min)
    @variable(model, q[H, K, V] >= 0)
    @variable(model, a[H, V] >= 0)

    @objective(model, Min, sum(data.vertices[v].inv_cost * s[t, v] + PEN * a[t, v] for t in H, v in V))

    @constraint(model, [t in H, v in V; v > 1], s[t, v] == (t == 1 ? data.vertices[v].inv_init : s[t - 1, v]) + sum(q[t, k, v] for k in K) - data.vertices[v].demand + a[t, v])
    @constraint(model, [t in H], s[t, 1] == (t == 1 ? data.vertices[1].inv_init : s[t - 1, 1]) - sum(q[t, k, 1] for k in K) + data.vertices[1].demand)
    @constraint(model, [t in H, k in K], sum(q[t, k, v] for v in V if v > 1) == q[t, k, 1])
    @constraint(model, [t in H, k in K], q[t, k, 1] <= data.capacity)
    @constraint(model, [t in H, v in V; v > 1], (t == 1 ? data.vertices[v].inv_init : s[t - 1, v]) + sum(q[t, k, v] for k in K) <= data.vertices[v].inv_max)

    return model
end

function solve!(formulation::Formulation, routes::Vector{Vector{Vector{Int64}}})
    for t in 1:formulation.data.num_periods, k in 1:formulation.data.num_vehicles
        fix.(formulation.model[:q][t, k, :], 0.0; force = true)
        for v in routes[t][k]
            if is_fixed(formulation.model[:q][t, k, v])
                unfix(formulation.model[:q][t, k, v])
            end
        end
    end

    optimize!(formulation.model)
    status = termination_status(formulation.model)
    if (status == MOI.OPTIMAL || (status == MOI.TIME_LIMIT && has_values(model)))
        return objective_value(formulation.model) + sum(vertex.inv_init * vertex.inv_cost for vertex in formulation.data.vertices)
    else
        return typemax(Int64)
    end
end
