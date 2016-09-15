# Optimal package install / uninstall
# http://www.cs.ucsd.edu/~lerner/papers/opium.pdf

import PicoSAT

index = Dict(
    "a" => Dict(:depends => ["b", "c", "z"]),
    "b" => Dict(:depends => ["d"]),
    "c" => Dict(:depends => ["d|e", "f|g"]),
    "d" => Dict(:conflicts => ["e"]),
    "e" => Dict(:conflicts => ["d"]),
    "f" => Dict(:conflicts => ["g"]),
    "g" => Dict(:conflicts => ["f"]),
    "y" => Dict(:depends => ["z"]),
    "z" => Dict{Any,Any}()
)

name2var = Dict{Any,Any}()
var2name = Dict{Any,Any}()

for (i,name) in enumerate(keys(index))
    name2var[name] = i
    var2name[i] = name
end

clauses = Any[]

function tocnf(name)
    # dependencies
    depends = get(index[name], :depends, Any[])
    for r in depends
        clause = Any[-(name2var[name])]
        append!(clause, Any[name2var[n] for n in split(r, '|')])
        push!(clauses, clause)
    end
    # conflicts
    conflicts = get(index[name], :conflicts, Any[])
    for c in conflicts
        push!(clauses, Any[-(name2var[name]), -(name2var[c])])
    end
end

map(tocnf, keys(index))

println(name2var)
push!(clauses, [name2var["a"]])

for sol in PicoSAT.itersolve(clauses)
    s = [var2name[v] for v in sol[sol .> 0]]
    println(sort(s))
end
