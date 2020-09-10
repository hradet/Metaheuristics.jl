### Initialize population
function initialize_population!(f::Function, lb, ub, method::Clearing, options::Options)

	# Parameters
	n = length(lb)

	# Pre-allocate pop
	method.population = zeros(method.nind * 2, n + 3)

	# Init pop
	if options.multithreads
		Threads.@threads for i in 1:method.nind
		    method.population[i,1:n] = lb .+ rand(n) .* (ub .- lb)
		    method.population[i,n+1] = unidrnd(3)
		    method.population[i,n+2] = 0
		    method.population[i,n+3] = f(method.population[i,1:n])
		end
	else
		for i in 1:method.nind
		    method.population[i,1:n] = lb .+ rand(n) .* (ub .- lb)
		    method.population[i,n+1] = unidrnd(3)
		    method.population[i,n+2] = 0
		    method.population[i,n+3] = f(method.population[i,1:n])
		end
	end
end

### Update population
function update_population!(f::Function, lb, ub, method::Clearing, options::Options)

	# Selection
	selection!(method)

	# Crossover
	crossover!(lb, ub, method)

	# Mutation
	mutation!(lb, ub, method)

	# Population assessment
	assessment!(f, method, options)

	# Eclaircissement
	clearing!(lb, ub, method)

	# Density indexes to the niches
	set_density!(method)
end

### Selection
function selection!(method::Clearing)
	# Parameter
	n = size(method.population, 2) - 3

    for i in 1:method.nind
		# Select randomly two parents from the parent pool
		i1 = unidrnd(method.nind)
        i2 = unidrnd(method.nind)
		# Individuals must be different...
        while i1 == i2
          i2 = unidrnd(method.nind)
        end
		# If i2 is stronger than i1, select i2
        method.population[i2,n+3] >= method.population[i1,n+3] && method.population[i2,n+2] > method.population[i1,n+2] ? i1 = i2 : nothing
		# Copy to the new generation
        method.population[method.nind+i,:] = method.population[i1,:]
    end
end

### Crossover
function crossover!(lb, ub, method::Clearing)
	# Parameter
	n = length(lb)

    for i in (method.nind + 1) : (2 * method.nind - 1)
		# Autoadaptative crossover
		if method.crossover == "auto"
			# Select randomly the crossover type
			bitrand(1)[1] ? select = method.population[i,n+1] : select = method.population[i+1,n+1]
			if select == 1.
				BLX!(i, lb, ub, method)
			elseif select == 2.
				vSBX!(i, lb, ub, method)
		    elseif select == 3.
				PNX!(i, lb, ub, method)
		    end
		# BLX crossover
		elseif method.crossover == "BLX"
			BLX!(i, lb, ub, method)
		# vSBX crossover
		elseif method.crossover == "vSBX"
			vSBX!(i, lb, ub, method)
		# PNX crossover
		elseif method.crossover == "PNX"
			PNX!(i, lb, ub, method)
		else
			println("Crossover method unknown...");
		end
	 end
end
# BLX-dec crossover
function BLX!(i, lb, ub, method::Clearing)
	# Parameter
	n = length(lb)
	# Chose randomly between [dec, 2 * dec + 1]
	δ = .- method.dec .+ rand(n) .* (2 .* method.dec .+ 1)
	#
	E1 = method.population[i,1:n] .+ δ .* (method.population[i+1,1:n] .- method.population[i,1:n])
	E2 = method.population[i+1,1:n] .+ δ .* (method.population[i,1:n] .- method.population[i+1,1:n])
	# Copy the children in the population with overshoot tests
	method.population[i,1:n] = max.(min.(ub, E1), lb)
	method.population[i+1,1:n] = max.(min.(ub, E2), lb)
	# Update crossover type
	method.population[i,n+1], method.population[i+1,n+1] = 1., 1.
end
# vSBX crossover
function vSBX!(i, lb, ub, method::Clearing)
	# Parameter
	n = length(lb)
	E1, E2 = zeros(n), zeros(n)

	for j in 1:n
		# Select randomly u between ]0,1[
		u = rand(1)[1]
		while u == 0. || u == 1.
			u = rand(1)[1]
		end
		#
		if  u <= 0.5
			β = 1. / (2. * u) ^ (1. / (method.η + 1.))
			E1[j] = 0.5 * ((1. + β) * method.population[i,j] + (1. - β) * method.population[i+1,j])
			E2[j] = 0.5 * ((1. - β) * method.population[i,j] + (1. + β) * method.population[i+1,j])
		else
			β = 1. / (2. * (1. - u)) ^( 1. / (method.η + 1.))
			E1[j] = 0.5 * (3. - β) * method.population[i,j] - (1. - β) * method.population[i+1,j]
			E2[j] = 0.5 * ((β - 1.) * method.population[i,j] + (3. - β) * method.population[i+1,j])
		end
	end
	# Copy the children in the population with overshoot tests
	method.population[i,1:n] = max.(min.(ub, E1), lb)
	method.population[i+1,1:n] = max.(min.(ub, E2), lb)
	# Update crossover type
	method.population[i,n+1], method.population[i+1,n+1] = 2., 2.
end
# PNX crossover
function PNX!(i, lb, ub, method::Clearing)
	# Parameter
	n = length(lb)
	#
	E1 = method.population[i,1:n] .+ abs.(method.population[i,1:n] .- method.population[i+1,1:n]) .* randn(n)
	E2 = method.population[i+1,1:n] .+ abs.(method.population[i,1:n] .- method.population[i+1,1:n]) .* randn(n)
	# Copy the children in the population with overshoot tests
	method.population[i,1:n] = max.(min.(ub, E1), lb)
	method.population[i+1,1:n] = max.(min.(ub, E2), lb)
	# Update crossover type
	method.population[i,n+1], method.population[i+1,n+1] = 3., 3.
end

### Mutations
function mutation!(lb, ub, method::Clearing)
	# Parameters
	n = length(lb)

    for i in (method.nind + 1) : (2 * method.nind)
		# Mutation poly
	    for j in 1:n
	        if rand(1)[1] < method.pm
	            u = rand(1)[1]
	            if u < 0.5
	                δ = 2. * u ^ (1. / (method.nm + 1.)) - 1.
				else
					δ = 1. - (2. * (1. - u)) ^ (1. / (method.nm + 1.))
	            end
				# Copy + overshoot
	            method.population[i,j] = min(max(method.population[i,j] + (ub[j]-lb[j]) * δ, lb[j]), ub[j])
	        end
	    end
		# Crossover gene mutation
	    if rand(1)[1] < method.pXgene
	       method.population[i,n+1] = unidrnd(3)
	    end
	end
end

### Assessment
function assessment!(f::Function, method::Clearing, options::Options)
    # Parameters
	n = size(method.population, 2) - 3
	# Asses the objective function
	if options.multithreads
	    Threads.@threads for i in (method.nind + 1) : (2 * method.nind)
	        method.population[i,n+3] = f(method.population[i,1:n])
	    end
	else
		for i in (method.nind + 1) : (2 * method.nind)
	        method.population[i,n+3] = f(method.population[i,1:n])
	    end
	end
end

### Clearing
function clearing!(lb, ub, method::Clearing)
   # Parameters
   n = length(lb)
   # Sort rows in ascending order from the fitness values
   method.population = sortrows!(method.population, n+3, order=true)
   #
   for i in 1 : (2 * method.nind)
      	if method.population[i,n+3] > -Inf
            ND = 1
            for j in (i + 1) : (2 * method.nind)
               	if method.population[j,n+3] > -Inf && norm((method.population[i,1:n] .- method.population[j,1:n]) ./ (ub .- lb), method.norm) < method.sigma
                 	ND < method.kapa ? ND = ND + 1 : method.population[j,n+3] = -Inf
           		end
        	end
      	end
   	end
end

### Density indexes to the niches
function set_density!(method::Clearing)
	# Parameters
    n = size(method.population, 2) - 3

	for i in 1 : (2 * method.nind)

		method.population[i,n+2] = 0.

		for j in 1:n

			method.population = sortrows!(method.population, j)

			δ = method.population[2 * method.nind,j] - method.population[1,j]

			if δ > 0.
				method.population[1, n+2] = Inf
				method.population[2 * method.nind, n+2] = Inf
				for k = 2 : (2 * method.nind - 1)
				 	method.population[k, n+2] < Inf ? method.population[k,n+2] = method.population[k,n+2] + (method.population[k+1,j] - method.population[k-1,j]) / δ : nothing
				end
			end
		end
	end
	# Sort in ascending order from the fitness and niches indexes
	# Pop = sortrows(Pop,[-(n+3) -(n+2)])
	method.population = sortrows!(method.population, n+3, order=true)
end
