# InventoryRoutingProblems.jl

<!-- [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://rafaelmartinelli.github.io/InventoryRoutingProblems.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://rafaelmartinelli.github.io/InventoryRoutingProblems.jl/dev)
[![Build Status](https://github.com/rafaelmartinelli/InventoryRoutingProblems.jl/workflows/CI/badge.svg)](https://github.com/rafaelmartinelli/InventoryRoutingProblems.jl/actions)
[![Coverage](https://codecov.io/gh/rafaelmartinelli/InventoryRoutingProblems.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/rafaelmartinelli/InventoryRoutingProblems.jl) -->
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

This package reads data files for Inventory Routing Problem (IRP) instances.

## Usage

The type used by the package is `InventoryRoutingProblem`, defined as follows:

```julia
struct InventoryRoutingProblem
    name::String                 # Instance name

    vertices::Vector{IRPVertex}  # Vertices data (see below)
    num_vehicles::Int64          # Number of vehicles
    num_periods::Int64           # Number of periods

    capacity::Int64              # Vehicles capacity
    costs::Matrix{Int64}         # Cost matrix (|V| x |V|)

    lb::Float64                  # Lower bound (-Inf if not known)
    ub::Float64                  # Upper bound ( Inf if not known)
end
```

Lower and upper bounds are from [DIMACS](http://dimacs.rutgers.edu/programs/challenge/vrp/irp/)'s results (I was a bit lazy on that).

The type `IRPVertex` is defined as follows:

```julia
struct IRPVertex
    id::Int64              # Sequential id

    inv_init::Int64        # Initial inventory
    inv_min::Int64         # Minimum inventory
    inv_max::Int64         # Maximum inventory
    inv_cost::Float64      # Inventory cost

    demand::Int64          # Demand

    coord::Vector{Float64} # Coordinates
end
```

Some classical IRP instances from the literature are preloaded, following [DIMACS](http://dimacs.rutgers.edu/programs/challenge/vrp/irp/) naming. For example, to load IRP instance `L_abs2n200_5_H`:

```julia
irp = loadIRP("L_abs2n200_5_H")
```

See the full list on the [DIMACS](http://dimacs.rutgers.edu/programs/challenge/vrp/irp/) page.

The package still does not load custom IRP instances.

## Installation

`InventoryRoutingProblems` is a registered Julia Package! yay!

You can install `InventoryRoutingProblems` through the Julia package manager.

Open Julia's interactive session (REPL) and type:

```julia
] add InventoryRoutingProblems
```

__Do not forget__ to :star:star:star: our package! :grin:

## Related links

- [DIMACS IRP Page](http://dimacs.rutgers.edu/programs/challenge/vrp/irp/)

## Other packages

- [Knapsacks.jl](https://github.com/rafaelmartinelli/Knapsacks.jl): Knapsack algorithms in Julia
- [FacilityLocationProblems.jl](https://github.com/rafaelmartinelli/FacilityLocationProblems.jl): Facility Location Problems Lib
- [AssignmentProblems.jl](https://github.com/rafaelmartinelli/AssignmentProblems.jl): Assignment Problems Lib
- [BPPLib.jl](https://github.com/rafaelmartinelli/BPPLib.jl): Bin Packing and Cutting Stock Problems Lib
- [CARPData.jl](https://github.com/rafaelmartinelli/CARPData.jl): Capacitated Arc Routing Problem Lib
- [MDVSP.jl](https://github.com/rafaelmartinelli/MDVSP.jl): Multiple-Depot Vehicle Scheduling Problem Lib
- [CVRPLIB.jl](https://github.com/chkwon/CVRPLIB.jl): Capacitated Vehicle Routing Problem Lib
- [TSPLIB.jl](https://github.com/matago/TSPLIB.jl): Traveling Salesman Problem Lib
