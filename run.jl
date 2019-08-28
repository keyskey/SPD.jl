# For parallel execution, run with $ julia -p (number of process) run.jl

using Distributed
@everywhere include("simulation.jl")
using .Simulation

const num_episode = 100
const population = 10000
const average_degree = 8
const topology_type = "Ring"  # ER | ScaleFree | Lattice | Ring

Distributed.pmap(episode -> Simulation.one_episode(episode, population, average_degree, topology_type), 1:num_episode)
