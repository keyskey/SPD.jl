include("decision.jl")

module Simulation
    using ..Society
    using ..Decision
    using CSV
    using DataFrames
    using Random
    
    function time_loop(society, init_c, dg, dr)
        initialize_strategy(society, init_c)
        init_fc = count_fc(society)
        fc_hist = [init_fc]
        println("Dg: $(dg), Dr: $(dr), Time: 0, Fc:$(init_fc)")
        for step = 1:1000
            count_payoff(society, dg, dr)
            pairwise_fermi(society)
            fc = count_fc(society)
            println("Dg: $(dg), Dr: $(dr), Time: $(step), Fc:$(fc)")
            push!(fc_hist, fc) 
            if fc == 0 || fc == 1 || step == 1000
                global solution = fc
                break
            elseif step >= 100 && (Statistics.mean(fc_hist[step-99:step])-fc)/fc <= 0.001
                global solution =  Statistics.mean(fc_hist[step-99:step])
                break
            end
        end

        return solution
    end

    function one_episode(episode, population, topology)
        society = SocietyType(population, topology)
        DataFrame(Dg = [], Dr = [], Fc = []) |> CSV.write("episode_$(episode).csv")
        init_c = choose_initial_cooperators(population)
        for dg = 0:0.1:1
            for dr = 0:0.1:1
                fc = time_loop(society, init_c, dg, dr)
                DataFrame(Dg = [dg], Dr = [dr], Fc = [fc]) |> CSV.write("episode_$(episode).csv", append=true)
            end
        end
    end
end
