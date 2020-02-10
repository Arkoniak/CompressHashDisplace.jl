module BenchConstruct
using BenchmarkTools
using CompressHashDisplace

suite = BenchmarkGroup()

DICTIONARY = joinpath(@__DIR__, "..", "assets", "american-english.txt")

dict = Dict{String, Int}()

for (line, word) in enumerate(readlines(DICTIONARY))
    dict[word] = line
end

suite["fd_construct"] = @benchmarkable FrozenDict($dict)
suite["fud_construct"] = @benchmarkable FrozenUnsafeDict($dict)

end # module

BenchConstruct.suite
