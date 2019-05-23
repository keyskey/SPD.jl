include("society.jl")

module Decision
    export choose_initial_cooperators, initialize_strategy!, count_payoff!, pairwise_fermi!, count_fc
    using StatsBase
    using ..Society

    function choose_initial_cooperators(population::Int)
        initial_cooperators::Vector{Int} = StatsBase.self_avoid_sample!(1:population, collect(1:div(population, 2)))

        return initial_cooperators
    end

    function initialize_strategy!(society::SocietyType, initial_cooperators::Vector{Int})
        for id in 1:society.population
            if id in initial_cooperators
                society.strategy[id] = "C"
            else
                society.strategy[id] = "D" 
            end
        end

        society
    end

    function count_payoff!(society::SocietyType, dg, dr)
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

        society
    end
    
    function pairwise_fermi!(society::SocietyType)
        next_strategy = copy(society.strategy)
        for id = 1:society.population
            opp_id = rand(society.neighbors_id[id])
            next_strategy[id] = ifelse(rand() < 1/(1+exp((society.point[id] - society.point[opp_id])/0.1)), society.strategy[opp_id], society.strategy[id])
        end
        society.strategy = next_strategy

        society
    end

    function count_fc(society::SocietyType)
        fc = length(filter(strategy -> strategy == "C", society.strategy))/society.population

        return fc
    end
end
