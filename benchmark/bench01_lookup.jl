module BenchLookup
using BenchmarkTools
using CompressHashDisplace

suite = BenchmarkGroup()

DICTIONARY = joinpath(@__DIR__, "..", "assets", "american-english.txt")

dict = Dict{String, Int}()

for (line, word) in enumerate(readlines(DICTIONARY))
    dict[word] = line
end

fd = FrozenDict(dict)
fud = FrozenUnsafeDict(dict)

word = "world"
suite["world_fd_lookup"] = @benchmarkable $fd[$word]
suite["world_fud_lookup"] = @benchmarkable $fud[$word]
suite["world_int_lookup"] = @benchmarkable $dict[$word]

word = "hello"
suite["hello_fd_lookup"] = @benchmarkable $fd[$word]
suite["hello_fud_lookup"] = @benchmarkable $fud[$word]
suite["hello_int_lookup"] = @benchmarkable $dict[$word]

word = "quintessential"
suite["quintessential_fd_lookup"] = @benchmarkable $fd[$word]
suite["quintessential_fud_lookup"] = @benchmarkable $fud[$word]
suite["quintessential_int_lookup"] = @benchmarkable $dict[$word]

end # module

BenchLookup.suite
