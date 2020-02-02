using Documenter, CompressHashDisplace

makedocs(;
    modules=[CompressHashDisplace],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/Arkoniak/CompressHashDisplace.jl/blob/{commit}{path}#L{line}",
    sitename="CompressHashDisplace.jl",
    authors="Andrey Oskin",
    assets=String[],
)

deploydocs(;
    repo="github.com/Arkoniak/CompressHashDisplace.jl",
)
