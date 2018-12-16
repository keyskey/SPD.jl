module Decision
    export choose_initial_cooperators, initialize_strategy, count_payoff, pairwise_fermi, count_fc
    using StatsBase

    function choose_initial_cooperators(population)
        init_c = StatsBase.self_avoid_sample!(1:population, [i for i = 1:Int(population/2)])

        return init_c
    end

    function initialize_strategy(society, init_c)
        for id = 1:society.population
            society.strategy[id] = ifelse(id in init_c, "C", "D")
        end
    end

    function count_payoff(society, dg, dr)
        R = 1
        T = 1+dg
        S = -dr
        P = 0

        for id = 1:society.population
            society.point[id] = 0
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
    
    function pairwise_fermi(society)
        for id = 1:society.population
            opp_id = rand(society.neighbors_id[id])
            society.next_strategy[id] = ifelse(rand() < 1/(1+exp((society.point[id] - society.point[opp_id])/0.1)), society.strategy[opp_id], society.strategy[id])
        end
        society.strategy = copy(society.next_strategy)
    end

    function count_fc(society)
        fc = length([1 for strategy in society.strategy if strategy == "C"])/society.population

        return fc
    end
end