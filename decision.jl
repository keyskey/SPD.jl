include("society.jl")

module Decision
    export choose_initial_cooperators, initialize_strategy, count_payoff, pairwise_fermi, count_fc
    using StatsBase
    using ..Society

    function choose_initial_cooperators(population::Int)
        init_c::Vector{Int} = StatsBase.self_avoid_sample!(1:population, [i for i = 1:Int(population/2)])

        return init_c
    end

    function initialize_strategy(society::SocietyType, init_c::Vector{Int})
        for id = 1:society.population
            if id in init_c
                society.strategy[id] = "C"
                society.num_c += 1
            else
                society.strategy[id] = "D" 
            end
        end
    end

    function count_payoff(society::SocietyType, dg, dr)
        R = 1.0
        T = 1.0+dg
        S = -dr
        P = 0.0

        for id = 1:society.population
            society.point[id] = 0.0
            for nb_id in society.neighbors_id[id]
                if society.strategy[id] == "C" && society.strategy[nb_id] == "C"
                    society.point[id] += R
                elseif society.strategy[id] == "D" && society.strategy[nb_id] == "C"
                    society.point[id] += T
                elseif society.strategy[id] == "C" && society.strategy[nb_id] == "D"
                    society.point[id] += S
                elseif society.strategy[id] == "D" && society.strategy[nb_id] == "D"
                    society.point[id] += P
                end
            end
        end
    end
    
    function pairwise_fermi(society::SocietyType, kappa)
        society.num_c = 0
        for id = 1:society.population
            opp_id = rand(society.neighbors_id[id])
            society.next_strategy[id] = ifelse(rand() < 1/(1+exp((society.point[id] - society.point[opp_id])/kappa)), society.strategy[opp_id], society.strategy[id])
            society.num_c += ifelse(society.next_strategy[id] == "C", 1, 0)
        end
        society.strategy = copy(society.next_strategy)
    end

    function count_fc(society::SocietyType)
        fc = society.num_c/society.population

        return fc
    end
end
