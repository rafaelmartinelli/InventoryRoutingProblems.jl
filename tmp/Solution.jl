mutable struct Solution
    routes::Vector{Vector{Vector{Int64}}}

    cost::Float64
    route_cost::Int64
    inventory_cost::Float64

    in_period::Vector{BitVector}
end
