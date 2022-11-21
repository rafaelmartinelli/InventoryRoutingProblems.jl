seed = 2
perc_init = 0.5
perc_final = 0.01
iterations = 10
mov_pertub = 5



function ILS(data::InventoryRoutingProblem)

    sol, left = constructive(data)
    route_cost = RouteEvaluate(data, sol)

    ini_temp = (perc_init * route_cost) / -log(perc_init);
    end_temp = (perc_final * route_cost) / -log(perc_final);
    factor = (end_temp / ini_temp) ^ (1 / iterations);
      
    temp = ini_temp

    sol, route_cost = localsearch(data, sol, route_cost)
    best_sol, best_route_cost = sol, route_cost
    new_sol, new_route_cost = sol, route_cost
       
    while temp > end_temp
        new_sol, new_route_cost = Pertub(data, sol, route_cost)
        new_sol, new_route_cost = localsearch(data, new_sol, new_route_cost)
        
        profit =  route_cost - best_sol_cost
        
        if profit < -EPS
            best_sol, best_route_cost = new_sol, new_route_cost 
        else
            prob = exp(-profit / temp)
            dice = rand()
            
            if (dice < prob)
                new_sol, new_route_cost = sol, route_cost 
            end          
        end
        temp = temp * factor
    end 
    return best_sol, best_route_cost
end





function localsearch(data, sol, route_cost)
    found = true
    while(found)
        found = false
        sol, route_cost, found = IntraShift(data, sol, route_cost)
        sol, route_cost, found = IntraSwap(data, sol, route_cost)
        sol, route_cost, found = IntraRelocate(data, sol, route_cost)
        sol, route_cost, found = InterSwap(data, sol, route_cost)
        sol, route_cost, found = InterRelocate(data, sol, route_cost)
    end
    return sol, route_cost
end

function Pertub(data, sol, route_cost)
    for i in 1:mov_pertub
        n = rand(1:5)
        if n == 1
            sol, route_cost = PertIntraShift(data, sol)
        elseif n == 2
            sol, route_cost, found = PertIntraSwap(data, sol)
        elseif n == 3
            sol, route_cost, found = PertIntraRelocate(data, sol)
        elseif n == 4
            sol, route_cost, found = PertInterSwap(data, sol)
        elseif n == 5
            sol, route_cost, found = PertInterRelocate(data, sol)
        end
    end
    return sol, route_cost
end
        
