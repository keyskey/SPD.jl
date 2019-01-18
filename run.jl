# Run this script with
# julia -p <number of process> run.jl 
# to parallel computing for different episode

@everywhere include("simulation.jl")
using .Simulation
using PyCall
using Distributed
@pyimport networkx as nx

const num_episode = 100
const population = 10000
const topology = nx.barabasi_albert_graph(population, 4)

Distributed.pmap(episode -> Simulation.one_episode(episode, population, topology), 1:num_episode)
