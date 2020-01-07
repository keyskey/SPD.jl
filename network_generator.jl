module NetworkGenerator
using LightGraphs
export generate_topology, get_all_neighbors

function generate_lattice(population::Int)
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

function generate_topology(population::Int, average_degree::Int, topology_type::Symbol)
    if topology_type == :ER
        g = LightGraphs.random_regular_graph(population, average_degree)
    elseif topology_type == :ScaleFree
        g = LightGraphs.barabasi_albert(population, div(average_degree, 2))
    elseif topology_type == :Lattice
        g = generate_lattice(population)
    elseif topology_type == :Ring
        g = LightGraphs.SimpleGraphs.CycleGraph(population)
    end

    return g
end

function get_all_neighbors(topology::SimpleGraph)
    return [LightGraphs.neighbors(topology, agent_id) for agent_id in 1:LightGraphs.nv(topology)]
end

end