include("society.jl")
include("decision.jl")

module Simulation
    export run, one_episode
    using ..Society
    using ..Decision
    using CSV
    using DataFrames
    
    function run(society, init_c, dg, dr)
        initialize_strategy(society, init_c)
        init_fc = count_fc(society)
        println("Dg: $(dg), Dr: $(dr), Time: 0, Fc:$(init_fc)")
        for step = 1:1000
            count_payoff(society, dg, dr)
            pairwise_fermi(society)
            global fc = count_fc(society)
            println("Dg: $(dg), Dr: $(dr), Time: $(step), Fc:$(fc)")
        end

        return fc
    end

    function one_episode(episode, population, topology)
        society = SocietyType(population, topology)
        DataFrame(Dg = [], Dr = [], Fc = []) |> CSV.write("result$(episode).csv")
        init_c = choose_initial_cooperators(population)
        for dg = 0:0.1:1
            for dr = 0:0.1:1
                fc = run(society, init_c, dg, dr)
                DataFrame(Dg = [dg], Dr = [dr], Fc = [fc]) |> CSV.write("result$(episode).csv", append=true)
            end
        end
    end
end

using .Simulation
using PyCall
@pyimport networkx as nx

const num_episode = 100
const population = 10000
const topology = nx.barabasi_albert_graph(population, 4)

for episode = 1:num_episode
    one_episode(episode, population, topology)
end