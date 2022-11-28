lib::String = "./tmp/inventory/lib/irp.dll"

struct MinCostFlow <: Inventory
    data::InventoryRoutingProblem

    function MinCostFlow(data::InventoryRoutingProblem)
        startGraph(data)
        return new(data)
    end
end

function startGraph(data::InventoryRoutingProblem)
    demands = ([ Cint(vertex.demand) for vertex in data.vertices ])
    inv_cost = ([ Cdouble(vertex.inv_cost) for vertex in data.vertices ])
    inv_ini = ([ Cint(vertex.inv_init) for vertex in data.vertices ])
    inv_min = ([ Cint(vertex.inv_min) for vertex in data.vertices ])
    inv_max = ([ Cint(vertex.inv_max == typemax(Int64) ? typemax(Cint) : vertex.inv_max) for vertex in data.vertices ])
    costs = ([ Cint.(data.costs[i, :]) for i in 1:length(data.vertices) ])

    ccall((:startGraph, lib), Cvoid, (Cint, Ptr{Cint}, Ptr{Cdouble},
        Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Ptr{Cint}}, Cint, Cint, Cint),
        length(data.vertices), demands, inv_cost, inv_ini, inv_min, inv_max,
        costs, data.num_periods, data.num_vehicles, data.capacity)
end

function solve!(flow::MinCostFlow, routes::Vector{Vector{Vector{Int64}}})
    v = Cint.(reduce(vcat, reduce(vcat, routes)) .- 1)
    cost = ccall((:getInventoryCost, lib), Cdouble, (Ptr{Cint}, Cint), v, length(v))
    cost = round(cost * 100) / 100
    return cost
end
