include("./game.jl")

module Simulation
using CSV, DataFrames, Statistics, Random, LightGraphs
using ..Game
export one_episode

function game_loop(model::Game.Model, payoff_matrix::Game.PayoffMatrix, episode::Int)
    Game.initialize_strategy!(model)
    initial_fc = count_fc(model)
    fc_hist = [initial_fc]
    dg, dr = payoff_matrix.dg, payoff_matrix.dr
    println("Episode: $(episode), Dg: $(dg), Dr: $(dr), Timestep: 0, Fc: $(initial_fc)")

    step = 0
    while true
        step += 1
        Game.count_payoff!(model, payoff_matrix)
        Game.pairwise_fermi!(model)
        fc = Game.count_fc(model)
        println("Episode: $(episode), Dg: $(dg), Dr: $(dr), Timestep: $(step), Fc: $(fc)")
        push!(fc_hist, fc)

        if step >= 100
            if (Statistics.mean(fc_hist[end-100:end-1]) - fc) / fc <= 0.001
                global solution = Statistics.mean(fc_hist[end-99:end])
                break
            else fc == 0 || 1
                global solution = fc
                break
            end
        end
    end

    return solution
end

function one_episode(population::Int, topology::SimpleGraph, episode::Int)
    Random.seed!()
    initial_cooperators = Game.choose_initial_cooperators(population)
    model = Game.Model(topology, initial_cooperators)
    dilemma_range = 0.0:0.1:1.0
    dg_hist, dr_hist, fc_hist = [], [], []

    for dg in dilemma_range, dr in dilemma_range
        payoff_matrix = Game.PayoffMatrix(dg, dr)
        fc = game_loop(model, payoff_matrix, episode)
        push!(dg_hist, dg)
        push!(dr_hist, dr)
        push!(fc_hist, fc)
    end

    DataFrame(Dg = dg_hist, Dr = dr_hist, Fc = fc_hist) |> CSV.write("./results/episode_$(episode).csv")
end

end
