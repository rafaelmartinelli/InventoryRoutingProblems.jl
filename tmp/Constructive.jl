function constructive(data::InventoryRoutingProblem)
    sol = [ [ Int64[] for _ in 1:data.num_vehicles ] for _ in 1:data.num_periods ]

    left = [ vertex.inv_init for vertex in data.vertices ]
    for t in 1:data.num_periods
        for v in 1:length(data.vertices)
            if v == 1
                left[v] += data.vertices[v].demand
            else
                left[v] -= data.vertices[v].demand
            end
        end
        
        k = 1
        capacity = 0
        while k <= data.num_vehicles
            if length(sol[t][k]) == 0
                push!(sol[t][k], 1)
            end
            
            # vejo qual o melhor vertice para colocar na rota
            best = -1
            best_cost = typemax(Int64)
            for v in 2:length(data.vertices)
                if left[v] < 0 && capacity - left[v] <= data.capacity
                    if data.costs[sol[t][k][end], v] < best_cost
                        best = v
                        best_cost = data.costs[sol[t][k][end], v]
                    end
                end
            end

            # se não conseguir adicionar nenhum vertice eu adiciono o deposito (finalizo a rota)
            if best == -1
                push!(sol[t][k], 1)
                k += 1
                capacity = 0
                continue
            end

            # adiciono o vertice na rota 
            push!(sol[t][k], best)
            left[1] += left[best]
            capacity -= left[best]
            left[best] = 0
        end
    end
    return sol, left
end
