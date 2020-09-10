# Rounded random numbers from discrete uniform distribution between [1,n]
unidrnd(n::Int64) = round(Int,rand(Uniform(1,n)))
# Sort rows based on the col reference
function sortrows!(A, col; order=false)
    if isa(col, Int)
        return A[sortperm(A[:,col], rev=order),:]
    else
        # Sorted along col[1]
        A_sorted = A[sortperm(A[:,col[1]], rev = order),:]
        # Break ties
    end
end
# Check convergence
isconverged!(new::Float64, old::Float64, reltol::Float64, iteration::Int64) = abs(new - old) / new <= reltol ? iteration += 1 : iteration = 0
# Check time
istimedout(t::Float64, t0::Float64, time_limit::Int64) = (t - t0) / 3600. > time_limit
# Status
function status(it::Int64, it_unchanged::Int64, timedout::Bool, options::Options)
    if it >= options.iterations
        status = "+ Status: Maximum iteration number is reached"
    elseif !timedout
        status = "+ Status: Timed out"
    elseif it_unchanged >= options.itmax_unchanged
        status = "+ Status: Converged"
    end
    return status
end
# Show results in REPL
function show_results(results::MetaheuristicResults)
    if results.options.log
        # Summary
        println("___")
        println("")
        println("Optimization summary...")
        println("___")
        println("")
        # Status
        println(results.status)
        # Minimizer
        println("+ Optimal decisions: ", results.minimizer)
        # Minimum
        println("+ Minimum: ", results.minimum)
        # Iteration
        println("+ Iterations: ", results.iterations)
    end
end
