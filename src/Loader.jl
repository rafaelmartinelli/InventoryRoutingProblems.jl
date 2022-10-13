function loadIRP(name::String)
    abs_name = joinpath(data_path, name * ".dat")
    raw = split(read(abs_name, String))

    num_vertices = parse(Int64, raw[1])
    num_periods = parse(Int64, raw[2])
    capacity = parse(Int64, raw[3])
    num_vehicles = parse(Int64, raw[4])

    vertices = [ IRPVertex(
        parse(Int64, raw[5]) + 1,
        parse(Int64, raw[8]),
        0,
        typemax(Int64),
        parse(Float64, raw[10]),
        parse(Int64, raw[9]),
        [ parse(Float64, raw[6]),
        parse(Float64, raw[7]) ]
    ) ]

    append!(vertices, [ IRPVertex(
        parse(Int64, raw[8(i - 1) + 3]) + 1,
        parse(Int64, raw[8(i - 1) + 6]),
        parse(Int64, raw[8(i - 1) + 8]),
        parse(Int64, raw[8(i - 1) + 7]),
        parse(Float64, raw[8(i - 1) + 10]),
        parse(Int64, raw[8(i - 1) + 9]),
        [ parse(Float64, raw[8(i - 1) + 4]),
        parse(Float64, raw[8(i - 1) + 5]) ]
    ) for i in 2:num_vertices ])

    costs = [ round(euclidean(vertices[v].coord, vertices[w].coord) + EPS) for v in 1:num_vertices, w in 1:num_vertices ]

    return InventoryRoutingProblem(name, vertices, num_vehicles, num_periods, capacity, costs, 0.0, Inf64)
end
