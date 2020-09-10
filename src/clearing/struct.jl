### Abstract metaheuristic
abstract type AbstractMetaheuristic end

### Clearing
mutable struct Clearing <: AbstractMetaheuristic
	# Parameters
	nind::Int64
	pm::Float64
	pXgene::Float64
	dec::Float64
	η::Float64
	nm::Float64
	crossover::String # crossover type
	kapa::Float64
	sigma::Float64
	norm::Union{Float64, Int64}
	# Population
	population::Array{Float64,2}

	Clearing(;nind = 50,
		pm = 0.05,
		pXgene = 0.05,
		dec = 0.5,
		eta1 = 1.,
		nm = 50.,
		crossover = "auto",
		kapa = 1.,
		sigma = 0.05,
		norm = Inf) =
		new(nind, pm, pXgene, dec, eta1, nm, crossover, kapa, sigma,norm)
end

mutable struct Options
	log::Bool
	reltol::Float64
	itmax_unchanged::Int64
	time_limit::Int64 # in hours
	iterations::Int64
	multithreads::Bool

	Options(;log = true,
		reltol = 1e-10,
		itmax_unchanged = 100,
		time_limit = 1,
		iterations = 100,
		multithreads = true) =
		new(log, reltol, itmax_unchanged, time_limit, iterations, multithreads)
end

### Results
mutable struct MetaheuristicResults
	method::AbstractMetaheuristic
	status::String
	minimizer::AbstractArray
	minimum::Float64
	iterations::Int64
	options::Options
end
