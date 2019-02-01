@everywhere include("simulation.jl")
using .Simulation
using PyCall
using Distributed
@pyimport networkx as nx
 
const num_episode = 100
const population = 100
const topology = nx.random_regular_graph(8, population) 

Distributed.pmap(episode -> Simulation.one_episode(episode, population, topology), 1:num_episode)
