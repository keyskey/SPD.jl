include("decision.jl")

module Simulation
    using ..Decision
    using ..Society
    using CSV
    using DataFrames
    using Statistics
    using Random
    
    function time_loop(society::SocietyType, initial_cooperators::Vector{Int}, episode::Int, dg, dr)
        tmax = 1000
        initialize_strategy!(society, initial_cooperators)
        init_fc = count_fc(society)
        fc_hist = zeros(tmax)
        fc_hist[1] = init_fc
        println("Episode: $(episode), Dg: $(dg), Dr: $(dr), Time: 0, Fc:$(init_fc)")
        for step = 2:1000
            fc = count_payoff!(society, dg, dr) |> pairwise_fermi! |> count_fc
            println("Episode: $(episode), Dg: $(dg), Dr: $(dr), Time: $(step), Fc:$(fc)")
            fc_hist[step] =  fc

            if fc == 0 || fc == 1
                global solution = fc
                break
            elseif (step >= 100 && (Statistics.mean(fc_hist[step-99:step])-fc)/fc <= 0.001) || step == tmax
                global solution =  Statistics.mean(fc_hist[step-99:step])
                break
            end
        end

        return solution
    end

    function one_episode(episode::Int, population::Int, average_degree::Int, topology_name::AbstractString)
        Random.seed!()
        society = SocietyType(population, average_degree, topology_name)
        DataFrame(Dg = [], Dr = [], Fc = []) |> CSV.write("episode_$(episode).csv")
        initial_cooperators = choose_initial_cooperators(population)
        for dg = 0.0:0.1:1.0
            for dr = 0.0:0.1:1.0
                fc = time_loop(society, initial_cooperators, episode, dg, dr)
                DataFrame(Dg = [dg], Dr = [dr], Fc = [fc]) |> CSV.write("episode_$(episode).csv", append=true)
            end
        end
    end
end
