function IntraShift(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}}, route_cost::Float64)
    found = true;
    while (found)
        found = false;
        for t in 1:data.num_periods
            for k in 1:data.num_vehicles
                for v in 2:length(sol[t][k] - 2)
                    if(length(sol[t][k] <= 3)) continue
                    sol = Swap(sol, t, k, v, v+1)
                    new_cost = RouteEvaluate(data, sol)
                    if (new_cost < route_cost)
                        route_cost = new_cost
                        found = true
                    else
                        sol = Swap(sol, t, k, v, v+1)
                    end
                end
            end
        end
    end

    return sol, route_cost, found
end

function PertIntraShift(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}})
    t = rand(1:length(data.num_periods))
    k = rand(1:length(data.num_vehicles))

    while(length(sol[t][k] <= 3))
        t = rand(1:length(data.num_periods))
        k = rand(1:length(data.num_vehicles))
    end

    v = rand(2:length(sol[t][k] - 2))
    sol = Swap(sol, t, k, v, v+1)
    new_cost = RouteEvaluate(data, sol)
    
    return sol, new_cost
end

function IntraSwap(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}}, route_cost::Float64)
    found = true;
    while (found)
        found = false;
        for t in 1:data.num_periods
            for k in 1:data.num_vehicles
                for v in 2:length(sol[t][k] - 3)
                    for z in (v+2):length(sol[t][k] - 1)
                        if(length(sol[t][k] <= 4)) continue
                        sol = Swap(sol, t, k, v, z)
                        new_cost = RouteEvaluate(data, sol)
                        if (new_cost < route_cost)
                            route_cost = new_cost
                            found = true
                        else
                            sol = Swap(sol, t, k, v, z)
                        end
                    end
                end
            end
        end
    end

    return sol, route_cost, found
end

function PertIntraSwap(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}})
    t = rand(1:length(data.num_periods))
    k = rand(1:length(data.num_vehicles))

    while(length(sol[t][k] <= 4))
        t = rand(1:length(data.num_periods))
        k = rand(1:length(data.num_vehicles))
    end

    v = rand(2:length(sol[t][k] - 3))
    z = rand((v+2):length(sol[t][k] - 1))
    sol = Swap(sol, t, k, v, z)
    new_cost = RouteEvaluate(data, sol)
    
    return sol, new_cost
end




function IntraRelocate(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}}, route_cost::Float64)
    found = true;
    while (found)
        found = false;
        for t in 1:data.num_periods
            for k in 1:data.num_vehicles
                for v in 2:length(sol[t][k] - 3)
                    for z in (v+2):length(sol[t][k] - 1)
                        if(length(sol[t][k] <= 4)) continue
                        vertice = sol[t][k][v]
                        deleteat!(sol[t][k], v)
                        insert!(sol[t][k], z, vertice)
                        new_cost = RouteEvaluate(data, sol)
                        if (new_cost < route_cost)
                            route_cost = new_cost
                            found = true
                        else
                            deleteat!(sol[t][k], z)
                            insert!(sol[t][k], v, vertice)
                        end
                    end
                end
            end
        end
    end

    return sol, route_cost, found
end

function PertIntraRelocate(data::InventoryRoutingProblem, sol::Vector{Vector{Vector{Int64}}})
    t = rand(1:length(data.num_periods))
    k = rand(1:length(data.num_vehicles))

    while(length(sol[t][k] <= 4))
        t = rand(1:length(data.num_periods))
        k = rand(1:length(data.num_vehicles))
    end

    v = rand(2:length(sol[t][k] - 3))
    z = rand((v+2):length(sol[t][k] - 1))
                  
    vertice = sol[t][k][v]
    deleteat!(sol[t][k], v)
    insert!(sol[t][k], z, vertice)
    new_cost = RouteEvaluate(data, sol)
    
    return sol, new_cost, found
end

function Swap(sol::Vector{Vector{Vector{Int64}}}, t::Int64, k::Int64, v::Int64, z::Int64)
{
    sol[t][k][v], sol[t][k][z] = sol[t][k][z], sol[t][k][v]
}