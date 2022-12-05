mutable struct LocalSearch
    data::InventoryRoutingProblem
    neighborhoods::Vector{Neighborhood}
    solution::Solution

    function LocalSearch(data::InventoryRoutingProblem, inventory::Inventory, solution::Solution)
        neighborhoods = Neighborhood[]
        push!(neighborhoods, Relocate(data, inventory, solution))
        push!(neighborhoods, Remove(data, inventory, solution))
        push!(neighborhoods, Shift(data, inventory, solution))
        push!(neighborhoods, Swap(data, inventory, solution))

        return new(data, neighborhoods, solution)
    end
end

function solve!(local_search::LocalSearch)
    moved = true
    while moved
        moved = false

        shuffle!(local_search.neighborhoods)
        for neighborhood in local_search.neighborhoods
            moved = localSearch!(neighborhood)
            if moved break end            
        end
    end
end

function perturb!(local_search::LocalSearch, moves::Int64 = 1)
    total = 0
    while total < moves
        neighborhood = rand(local_search.neighborhoods)
        if random!(neighborhood)
            total += 1
        end
    end
end

function setSolution(local_search::LocalSearch, solution::Solution)
    local_search.solution = solution
    for neighborhood in local_search.neighborhoods
        neighborhood.solution = solution
    end
end
