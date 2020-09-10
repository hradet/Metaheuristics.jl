using Metaheuristics, Seaborn
pygui(true)

# Define the foxhole function
function  foxhole(x)
    a = [-32 -16 0 16 32 -32 -16 0 16 32 -32 -16 0 16 32 -32 -16 0 16 32 -32 -16 0 16 32;
         -32 -32 -32 -32 -32 -16 -16 -16 -16 -16 0 0 0 0 0 16 16 16 16 16 32 32 32 32 32]
    return 500. .- 1. ./ (0.002 .+ sum( 1. ./ (j .+ 1. .+ (x[1] .- a[1,j]) .^ 6. .+ (x[2] .- a[2,j]) .^ 6.) for j in 1:size(a,2)))
end

# Bounds
lb, ub = [-50, -50], [50, 50]

# Optimize
@elapsed results = Metaheuristics.optimize(foxhole, lb, ub,
                                           Metaheuristics.Clearing(),
                                           options = Metaheuristics.Options(multithreads=false))

# Plots
X, Y = -50:1:50, permutedims(-50:1:50)
plot_surface(repeat(Y,length(Y),1), repeat(X,1,length(X)), foxhole([X,Y]), rstride=2,cstride=1, color="gray")
scatter3D(results.method.population[:,1], results.method.population[:,2], zs=results.method.population[:,5], c="red")
