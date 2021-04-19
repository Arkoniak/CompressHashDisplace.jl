module TestIterate
using CompressHashDisplace
using Test

@testset "FrozenDict iterate" begin
    dict = Dict("test$i" => i for i = 1:10)
    fdict = FrozenDict(dict)

    @test length(fdict) == length(dict)
    i = 0
    for (k, v) in fdict
        @test v == dict[k]
        i += 1
    end
    @test i == length(fdict)
end
@testset "Nonstring iterate" begin
    dict = Dict(i => 2i for i = 1:10)
    fdict = FrozenDict(dict)

    @test length(fdict) == length(dict)
    i = 0
    for (k, v) in fdict
        @test v == dict[k]
        i += 1
    end
    @test i == length(fdict)
end

end # module
