include("decision.jl")

module Simulation
<<<<<<< HEAD
=======
    using ..Society
>>>>>>> 87e446c43dab90f3ffbb989b0007a96754b27423
    using ..Decision
    using ..Society
    using CSV
    using DataFrames
<<<<<<< HEAD
    using Statistics
    using Random
    
    function time_loop(society::SocietyType, init_c::Vector{Int}, episode::Int, beta::Float16, dg::Float16, dr::Float16)
        initialize_strategy(society, init_c)
        init_fc = count_fc(society)
        fc_hist = [init_fc]
        println("Episode: $(episode), Beta: $(beta), Dg: $(dg), Dr: $(dr), Time: 0, Fc:$(init_fc)")
        for step = 1:1000
            count_payoff(society, dg, dr)
            pairwise_fermi(society, 1/beta)
            fc = count_fc(society)
            #println("Episode: $(episode), Beta: $(beta), Dg: $(dg), Dr: $(dr), Time: $(step), Fc:$(fc)")
            push!(fc_hist, fc)

=======
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
>>>>>>> 87e446c43dab90f3ffbb989b0007a96754b27423
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

<<<<<<< HEAD
    function one_episode(episode::Int, population::Int, topology)
        Random.seed!()
        society::SocietyType = SocietyType(population, topology)
        DataFrame(Beta = [], Dg = [], Dr = [], Fc = []) |> CSV.write("episode_$(episode).csv")
        init_c = choose_initial_cooperators(population)
        for beta::Float16 in [10]
            for dg::Float16 = -1.0:0.1:1.0
                for dr::Float16 = -1.0:0.1:1.0
                    fc = time_loop(society, init_c, episode, beta, dg, dr)
                    DataFrame(Beta = [beta], Dg = [dg], Dr = [dr], Fc = [fc]) |> CSV.write("episode_$(episode).csv", append=true)
                end
=======
    function one_episode(episode, population, topology)
        society = SocietyType(population, topology)
        DataFrame(Dg = [], Dr = [], Fc = []) |> CSV.write("episode_$(episode).csv")
        init_c = choose_initial_cooperators(population)
        for dg = 0:0.1:1
            for dr = 0:0.1:1
                fc = time_loop(society, init_c, dg, dr)
                DataFrame(Dg = [dg], Dr = [dr], Fc = [fc]) |> CSV.write("episode_$(episode).csv", append=true)
>>>>>>> 87e446c43dab90f3ffbb989b0007a96754b27423
            end
        end
    end
end
<<<<<<< HEAD

=======
>>>>>>> 87e446c43dab90f3ffbb989b0007a96754b27423
