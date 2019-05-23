module Society
    export SocietyType
    using LightGraphs

    mutable struct SocietyType
        population::Int
        strategy::Vector{AbstractString}
        point::Vector{Float64}
        neighbors_id::Vector{Vector{Int}}
    end

    function SocietyType(population::Int, average_degree::Int, topology_name::AbstractString)
        strategy     = fill("D", population)
        point        = zeros(population)
        topology     = generate_topology(population, average_degree, topology_name)
        neighbors_id = [LightGraphs.neighbors(topology, i) for i = 1:population]

        return SocietyType(population, strategy, point, neighbors_id)
    end

    function generate_topology(population::Int, average_degree::Int, topology_name::AbstractString)
        if topology_name == "ER"
            g = LightGraphs.random_regular_graph(population, average_degree)
        elseif topology_name == "SF"
            g = LightGraphs.barabasi_albert(population, div(average_degree, 2))
        elseif topology_name == "Lattice"
            n::Int = sqrt(population)
            g = LightGraphs.Grid([n, n], periodic = true)

            for x in 2:n-1
                for y in 2:n-1
                    # iからjにエッジを貼る
                    i = (x-1)*n + y
                    add_edge!(g, i, i+n+1) # 右上
                    add_edge!(g, i, i+n-1) # 右下
                    add_edge!(g, i, i-n+1) # 左上
                    add_edge!(g, i, i-n-1) # 左下
                end
            end

            # 左下のノード(1)
            add_edge!(g, 1, n*(n-1)+2)
            add_edge!(g, 1, population)
            add_edge!(g, 1, 2n)

            # 左上のノード(n)
            add_edge!(g, n, n*(n-1)+1)
            add_edge!(g, n, population-1)
            add_edge!(g, n, n+1)

            # 右下のノード(n(n-1)+1)
            add_edge!(g, n*(n-1)+1, n)
            add_edge!(g, n*(n-1)+1, n*(n-1))

            # x = 1上, y = 2〜n-1
            for y in 2:n-1
                add_edge!(g, y, n*(n-1)+y-1) # 左下
                add_edge!(g, y, n*(n-1)+y+1) # 左上
                add_edge!(g, y, y+n+1)       # 右上
                add_edge!(g, y, y+n-1)       # 右下
            end

            # y = 1上, x = 2 〜 n-1
            for x in n+1:n:n*(n-2)+1
                add_edge!(g, x, x-1)
                add_edge!(g, x, x+2n-1)
                add_edge!(g, x, x-n+1)
                add_edge!(g, x, x+n+1)
            end

            # y = n上, x = 2 〜 n-1
            for x in 2n:n:n*(n-1)
                add_edge!(g, x, x+n-1)
            end
        end

        return g
    end
end
