module Simulation
include("./society.jl")
using .Society
using CSV
using DataFrames
using Statistics
using Random
export one_episode

function time_loop(society::SocietyType, initial_cooperators::Vector{Int}, episode::Int, dg, dr, kappa)
    tmax = 1000
    initialize_strategy!(society, initial_cooperators)
    init_fc = count_fc(society)
    fc_hist = [init_fc]

    println("Episode: $(episode), Dg: $(dg), Dr: $(dr), Time: 0, Fc:$(init_fc)")
    for step in 1:tmax
        fc = count_payoff!(society, dg, dr) |> (s -> pairwise_fermi!(s, kappa)) |> count_fc
        println("Episode: $(episode), Dg: $(dg), Dr: $(dr), Time: $(step), Fc:$(fc)")
        push!(fc_hist, fc)
        if fc == 0 || fc == 1
            global solution = fc
            break
        elseif (step >= 100 && (Statistics.mean(fc_hist[end-100:end-1])-fc)/fc <= 0.001) || step == tmax
            global solution =  Statistics.mean(fc_hist[end-99:end])
            break
        end
    end
    return solution
end

function one_episode(episode::Int, population::Int, average_degree::Int, topology_type::AbstractString)
    Random.seed!()
    society = SocietyType(population, average_degree, topology_type)

    if isdir("./results") == false
        run(`mkdir results`)
    end

    DataFrame(Dg = [], Dr = [], Fc = []) |> CSV.write("./results/episode_$(episode).csv")
    initial_cooperators = choose_initial_cooperators(population)
    beta_range = [0.1, 1, 10]
    kappa_range = 1 ./ beta_range
    for kappa in kappa_range
        for dg in -1:0.1:1
            for dr in -1:0.1:1
                fc = time_loop(society, initial_cooperators, episode, dg, dr, kappa)
                DataFrame(Dg = [dg], Dr = [dr], Fc = [fc]) |> CSV.write("./results/episode_$(episode).csv", append=true)
            end
        end
    end
end

end
