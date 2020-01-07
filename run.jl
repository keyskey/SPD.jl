# For parallel execution,
# run with $ julia -p (number of process) run.jl

using Distributed
@everywhere include("simulation.jl")

include("./network_generator.jl")
using .NetworkGenerator

const population = 10000
const average_degree = 8
const topology_type = :ScaleFree  # :ER | :ScaleFree | :Lattice | :Ring
const topology = NetworkGenerator.generate_topology(population, average_degree, topology_type)
const num_episode = 1

if isdir("./results") == false
    run(`mkdir results`)
end

Distributed.pmap(episode -> Simulation.one_episode(population, topology, episode), 1:num_episode)