struct IRPVertex
    id::Int64

    inv_init::Int64
    inv_min::Int64
    inv_max::Int64
    inv_cost::Float64

    demand::Int64

    coord::Vector{Float64}
end

function Base.show(io::IO, vertex::IRPVertex)
    print(io, "V[", vertex.id, "]")
end

struct InventoryRoutingProblem
    name::String

    vertices::Vector{IRPVertex}
    num_vehicles::Int64
    num_periods::Int64

    capacity::Int64
    costs::Matrix{Int64}

    lb::Float64
    ub::Float64
end

function Base.show(io::IO, data::InventoryRoutingProblem)
    print(io, "IRP ", data.name)
    print(io, " (n = ", length(data.vertices),",")
    print(io, " H = ", data.num_periods, ",")
    print(io, " |K| = ", data.num_vehicles, ")")
    print(io, " [", data.lb, ", ", data.ub, "]")
end
