function nde2lg(in_file_name::String, out_file_name::String)
    open(out_file_name, "w") do io
        for line in eachline(in_file_name)
            uv = split(line, " ")
            u = parse(Int64, uv[1])
            v = parse(Int64, uv[2])
            new_line = string((u + 1), ",", (v + 1))
            println(io, new_line)
        end
    end
end