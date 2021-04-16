module TestLookup
using CompressHashDisplace
using Test

@testset "FrozenDict Lookup" begin
    dict = Dict{String, Int}("hello" => 1, "world" => 2)
    fd = FrozenDict(dict)
    @test fd["hello"] == 1
    @test fd["world"] == 2
    @test_throws KeyError fd["goodbye"]

    fud = FrozenUnsafeDict(dict)
    @test fd["hello"] == 1
    @test fd["world"] == 2
end

end # module