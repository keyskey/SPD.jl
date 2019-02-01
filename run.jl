using PyCall
using Distributed
@pyimport networkx as nx
@everywhere include("simulation.jl")
using .Simulation
 
const num_episode = 1
const population = 10000
const topology = nx.random_regular_graph(8, population) 

Distributed.pmap(episode -> Simulation.one_episode(episode, population, topology), 1:num_episode)
