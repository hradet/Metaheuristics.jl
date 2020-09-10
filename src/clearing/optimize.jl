function optimize(f::Function,
				  lb, ub,
				  method::AbstractMetaheuristic;
				  options = Options())

    # Parameters
    it = 0
	it_unchanged, old_obj = 0, NaN
	timedout, t0 = false, time()

    # Initialize pop
    initialize_population!(f, lb, ub, method, options)

    # Algorithm
    while it < options.iterations && it_unchanged < options.itmax_unchanged && !timedout
		# Iteration
        it += 1

		# Update population
		update_population!(f, lb, ub, method, options)

		# Check convergence
		it_unchanged = isconverged!(method.population[1,end], old_obj, options.reltol, it_unchanged)

		# Store the objective value for convergence checking
		old_obj = method.population[1,end]

		# Check timing
		timedout = istimedout(time(), t0, options.time_limit)
    end

	# Results
	results = MetaheuristicResults(method,
	status(it, it_unchanged, timedout, options),
	method.population[1,1:length(lb)],
	method.population[1,end],
	it,
	options)

	# Print results to the REPL
	show_results(results)

    return results
end
