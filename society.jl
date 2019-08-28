module Society
using StatsBase
include("./network_generator.jl")
using .NetworkGenerator
export SocietyType, choose_initial_cooperators, initialize_strategy!, count_payoff!, pairwise_fermi!, count_fc

const cooperation = 1
const defection = 0

mutable struct SocietyType
    population::Int
    strategies::Vector{Int}
    points::Vector{Float64}
    neighbors_id::Vector{Vector{Int}}

    SocietyType(population::Int, average_degree::Int, topology_type::AbstractString) = new(
        population,
        fill(cooperation, population),
        zeros(population),
        generate_topology(population, average_degree, topology_type) |> generate_neighbors_list
    )
end

function choose_initial_cooperators(population::Int)
    initial_cooperators = StatsBase.self_avoid_sample!(1:population, collect(1:div(population, 2)))

    return initial_cooperators
end

function initialize_strategy!(society::SocietyType, initial_cooperators::Vector{Int})
    for id in 1:society.population
        if id in initial_cooperators
            society.strategies[id] = cooperation
        else
            society.strategies[id] = defection
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
        society.points[id] = 0.0
        for nb_id in society.neighbors_id[id]
            if society.strategies[id] == cooperation && society.strategies[nb_id] == cooperation
                society.points[id] += R
            elseif society.strategies[id] == defection && society.strategies[nb_id] == cooperation
                society.points[id] += T
            elseif society.strategies[id] == cooperation && society.strategies[nb_id] == defection
                society.points[id] += S
            elseif society.strategies[id] == defection && society.strategies[nb_id] == defection
                society.points[id] += P
            end
        end
    end

    society
end

function pairwise_fermi!(society::SocietyType, kappa)
    next_strategy = copy(society.strategies)
    for id = 1:society.population
        opp_id = rand(society.neighbors_id[id])
        next_strategy[id] = ifelse(rand() < 1/(1+exp((society.points[id] - society.points[opp_id])/kappa)), society.strategies[opp_id], society.strategies[id])
    end
    society.strategies = next_strategy

    society
end

function count_fc(society::SocietyType)
    fc = length(society.strategies[society.strategies .== cooperation])/society.population

    return fc
end

end
