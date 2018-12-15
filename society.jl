module Society
    export SocietyType

    mutable struct SocietyType
        population::Int
        strategy::Vector{AbstractString}
        next_strategy::Vector{AbstractString}
        point::Vector{Float32}
        neighbors_id::Vector{Vector{Int}}

        SocietyType(population, topology) = new(population,
                                                ["D" for i = 1:population],
                                                ["D" for i = 1:population],
                                                [0 for i = 1:population],    
                                                [[nb_id+1 for nb_id in topology[i]] for i = 1:population]   # [Vector(LightGraphs.neighbors(topology, i)) for i = 1:population] if using Lightgraphs
                                                )
    end
end
