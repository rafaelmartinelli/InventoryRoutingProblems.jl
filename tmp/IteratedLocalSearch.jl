struct IteratedLocalSearch
    data::InventoryRoutingProblem
end

function solve!(ils::IteratedLocalSearch)
    print("Inventory... ")
    inventory = MinCostFlow(ils.data)
    println("Built!\n")
    
    println("Constructive... ")
    constructive = DemandLeft(ils.data, inventory)
    @time solution = solve!(constructive)
    @printf("Total = %.2f (routing = %.2f, inventory = %.2f)\n\n", solution.cost, solution.route_cost, solution.inventory_cost)

    println("Local search...")
    local_search = LocalSearch(ils.data, inventory, solution)
    @time solve!(local_search)
    @printf("Total = %.2f (routing = %.2f, inventory = %.2f)\n\n", solution.cost, solution.route_cost, solution.inventory_cost)

    current = deepcopy(solution)
    best = deepcopy(solution)

    perc_init = 0.5
    perc_final = 0.01
    iterations = 50
    perturbations = 3

    ini_temp = (perc_init * solution.cost) / -log(perc_init)
    end_temp = (perc_final * solution.cost) / -log(perc_final)
    factor = (end_temp / ini_temp) ^ (1 / iterations)

    temp = ini_temp
    while temp > end_temp
        perturb!(local_search, perturbations)
        solve!(local_search)
        @printf("Solution = %.2f - Current = %.2f - Best = %.2f\n", solution.cost, current.cost, best.cost)
        
        profit = solution.cost - current.cost

        prob = exp(-profit / temp)
        dice = rand()

        if dice - prob < -EPS
            current = deepcopy(solution)
            if solution.cost - best.cost < -EPS
                best = deepcopy(solution)
            end
        else
            solution = deepcopy(current)
            setSolution(local_search, solution)
        end      

        temp = temp * factor
    end

    return solution
end
