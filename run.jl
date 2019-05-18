# Before running this code in parallel, please remove the comment out in the line 5,17 and comment out the line 6 and 16. Then run;
# $ julia -p (number of process) run.jl

using Distributed
# @everywhere include("simulation.jl")
include("simulation.jl")
using .Simulation

using PyCall
@pyimport networkx as nx
 
const num_episode = 1
const population = 10000
const topology = nx.random_regular_graph(8, population) 

map(episode -> Simulation.one_episode(episode, population, topology), 1:num_episode)
#Distributed.pmap(episode -> Simulation.one_episode(episode, population, topology), 1:num_episode)
