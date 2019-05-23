# Before running this code in parallel, please remove the comment out in the line 5,17 and comment out the line 6 and 16. Then run;
# $ julia -p (number of process) run.jl

using Distributed
# @everywhere include("simulation.jl")
include("simulation.jl")
using .Simulation
 
const num_episode = 1
const population = 100
const average_degree = 8
const topology_name = "Lattice"

map(episode -> Simulation.one_episode(episode, population, average_degree, topology_name), 1:num_episode)
#Distributed.pmap(episode -> Simulation.one_episode(episode, population, topology), 1:num_episode)
