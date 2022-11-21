function InterSwap(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}}, route_cost::Float64)
    found = true;
    while (found)
        found = false;
        for t in 1:data.num_periods
            for k1 in 1:(data.num_vehicles - 1)
                if (length(sol[t][k1] <= 2)) continue
                for k2 in (k1+1):data.num_vehicles
                    if (length(sol[t][k2] <= 2)) continue
                    for v in 2:length(sol[t][k1] - 1)
                        for z in 2:length(sol[t][k2] - 1)
                            sol = SwapInter(sol, t, k1, k2, v, z)
                            new_cost = RouteEvaluate(data, sol)
                            if (new_cost < route_cost)
                                route_cost = new_cost
                                found = true
                            else
                                sol = Swap(sol, t, k1, k2, v, z)
                            end
                        end
                    end
                end
            end
        end
    end

    return sol, route_cost, found
end

function PertInterSwap(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}})
    t = rand(1:length(data.num_periods))
    k1 = rand(1:length(data.num_vehicles))
    k2 = rand(1:length(data.num_vehicles))

    while (length(sol[t][k1] <= 2) || k1 == k2 || length(sol[t][k2] <= 2))
        t = rand(1:length(data.num_periods))
        k1 = rand(1:length(data.num_vehicles))
        k2 = rand(1:length(data.num_vehicles))
    end

    v = rand(2:length(sol[t][k1] - 1))
    z = rand(2:length(sol[t][k2] - 1))

    sol = SwapInter(sol, t, k1, k2, v, z)
    new_cost = RouteEvaluate(data, sol)
                                                       
    return sol, new_cost
end

function InterRelocate(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}}, route_cost::Float64)
    found = true;
    while (found)
        found = false;
        for t in 1:data.num_periods
            for k1 in 1:(data.num_vehicles - 1)
                if (length(sol[t][k1] <= 2)) continue
                for k2 in (k1+1):data.num_vehicles
                    if (length(sol[t][k2] <= 2)) continue
                    for v in 2:length(sol[t][k1] - 1)
                        for z in 2:length(sol[t][k2] - 1)
                            vertice = sol[t][k1][v]
                            deleteat!(sol[t][k1], v)
                            insert!(sol[t][k2], z, vertice)
                            new_cost = RouteEvaluate(data, sol)
                            if (new_cost < route_cost)
                                route_cost = new_cost
                                found = true
                            else
                                deleteat!(sol[t][k2], z)
                                insert!(sol[t][k1], v, vertice)
                            end
                        end
                    end
                end
            end
        end
    end

    return sol, route_cost, found
end

function PertInterRelocate(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}})
    t = rand(1:length(data.num_periods))
    k1 = rand(1:length(data.num_vehicles))
    k2 = rand(1:length(data.num_vehicles))

    while (length(sol[t][k1] <= 2) || k1 == k2 || length(sol[t][k2] <= 2))
        t = rand(1:length(data.num_periods))
        k1 = rand(1:length(data.num_vehicles))
        k2 = rand(1:length(data.num_vehicles))
    end

    v = rand(2:length(sol[t][k1] - 1))
    z = rand(2:length(sol[t][k2] - 1))
              
    vertice = sol[t][k1][v]
    deleteat!(sol[t][k1], v)
    insert!(sol[t][k2], z, vertice)
    new_cost = RouteEvaluate(data, sol)

    return sol, new_cost
end



function SwapInter(sol::Vector{Vector{Vector{Int64}}}, t::Int64, k1::Int64, k2::Int64, v::Int64, z::Int64)
{
    sol[t][k1][v], sol[t][k2][z] = sol[t][k2][z], sol[t][k1][v]
}