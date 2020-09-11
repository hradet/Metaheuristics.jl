# Metaheuristics

A Julia package for metaheuristic algorithms.

# Installation
In order to use the package, follow the [managing package guideline](https://julialang.github.io/Pkg.jl/v1/managing-packages/) for uneregistred packages.

# Algorithms
* Clearing

# Example
We provide a simple example with the multimodal foxhole function (also know as shekel function).

```Julia
using Metaheuristics

# Define the foxhole function
function  foxhole(x)
    a = [-32 -16 0 16 32 -32 -16 0 16 32 -32 -16 0 16 32 -32 -16 0 16 32 -32 -16 0 16 32;
         -32 -32 -32 -32 -32 -16 -16 -16 -16 -16 0 0 0 0 0 16 16 16 16 16 32 32 32 32 32]
    return 500. .- 1. ./ (0.002 .+ sum( 1. ./ (j .+ 1. .+ (x[1] .- a[1,j]) .^ 6. .+ (x[2] .- a[2,j]) .^ 6.) for j in 1:size(a,2)))
end

# Bounds
lb, ub = [-50, -50], [50, 50]

# Optimize
results = Metaheuristics.optimize(foxhole, lb, ub,
                                  Metaheuristics.Clearing(),
                                  options = Metaheuristics.Options())

```
The different options could be passed using the ```options = Metaheuristics.Options()``` argument (see source code for more informations about the available options). Note that computations could be **parallelized** using multi-threading.




