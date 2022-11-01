function loadIRP(name::String)::Union{InventoryRoutingProblem, Nothing}
    raw = getRawData(name)
    if raw === nothing return nothing end

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

    return InventoryRoutingProblem(name, vertices, num_vehicles, num_periods, capacity, costs, loadBounds(name)...)
end

function getRawData(name::String)::Union{Vector{String}, Nothing}
    data_file = joinpath(data_path, "data.7z")
    file_name = name * ".dat"

    run(pipeline(`$(p7zip()) e $data_file -y -o$data_path $file_name`; stdout = devnull, stderr = devnull))

    abs_file_name = joinpath(data_path, file_name)
    if !isfile(abs_file_name)
        println("File $(string(instance)) not found!")
        return nothing
    end

    raw = split(read(abs_file_name, String))
    rm(abs_file_name)

    return raw
end
