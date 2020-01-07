include("./network_generator.jl")

module Game
using StatsBase, Statistics, LightGraphs
using ..NetworkGenerator
export Model, choose_initial_cooperators, initialize_strategy!, count_payoff!, pairwise_fermi!, count_fc

mutable struct Agent
    strategy::Symbol
    payoff::Float64
    neighbors_id::Vector{Int}

    Agent(neighbors_id::Vector{Int}) = new(
        Symbol(""),
        0.0,
        neighbors_id
    )
end

mutable struct Model
    initial_cooperators::Vector{Int}
    agents::Vector{Agent}
end

function Model(topology:: SimpleGraph, initial_cooperators::Vector{Int})
    all_neighbors = NetworkGenerator.get_all_neighbors(topology)

    model = Model(
        initial_cooperators,
        [Agent(neighbors_id) for neighbors_id in all_neighbors]
    )

    return model
end

struct PayoffMatrix
    dg::Float64
    dr::Float64
    R::Float64
    S::Float64
    T::Float64
    P::Float64

    PayoffMatrix(dg::Float64, dr::Float64) = new(
        dg,
        dr,
        1.0,
        -dr,
        1.0 + dg,
        0.0
    )
end

function choose_initial_cooperators(population::Int)
    initial_cooperators = StatsBase.self_avoid_sample!(1:population, collect(1:div(population, 2)))

    return initial_cooperators
end

function initialize_strategy!(model::Model)
    for (id, agent) in enumerate(model.agents)
        if id in model.initial_cooperators
            agent.strategy = :C
        else
            agent.strategy = :D
        end
    end
end

function count_payoff!(model::Model, payoff_matrix::PayoffMatrix)
    for agent in model.agents
        agent.payoff = 0.0

        for nb_id in agent.neighbors_id
            neighbor = model.agents[nb_id]

            if agent.strategy == :C && neighbor.strategy == :C
                agent.payoff += payoff_matrix.R
            elseif agent.strategy == :D && neighbor.strategy == :C
                agent.payoff += payoff_matrix.T
            elseif agent.strategy == :C && neighbor.strategy == :D
                agent.payoff += payoff_matrix.S
            elseif agent.strategy == :D && neighbor.strategy == :D
                agent.payoff += payoff_matrix.P
            end
        end
    end
end

function pairwise_fermi!(model::Model)
    for agent in model.agents
        opponent_id = rand(agent.neighbors_id)
        neighbor = model.agents[opponent_id]

        if neighbor.strategy != agent.strategy && rand() < 1 / ( 1 + exp((agent.payoff - neighbor.payoff) / 0.1 ) )
            agent.strategy = neighbor.strategy
        end
    end
end

function count_fc(model::Model)
    fc = [ifelse(agent.strategy == :C, 1, 0) for agent in model.agents]  |> Statistics.mean

    return fc
end

end
