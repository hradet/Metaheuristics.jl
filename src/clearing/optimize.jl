function optimize(f::Function,
				  lb, ub,
				  method::AbstractMetaheuristic;
				  options = Options())

    # Parameters
    it = 0
	it_unchanged, old_obj = 0, NaN
	timedout, t0 = false, time()

    # Initialize pop
	println("Population initialization...")
    initialize_population!(f, lb, ub, method, options)

    # Algorithm
	println("Starting optimization...")
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

		# Verbose
		options.verbose ? show_verbose(it, time() - t0, method.population[1,end]) : nothing
    end

	# Results
	results = MetaheuristicResults(method,
	get_status(it, it_unchanged, timedout, options),
	method.population[1,1:length(lb)],
	method.population[1,end],
	it,
	options)

	# Print results to the REPL
	show_results(results)

    return results
end
