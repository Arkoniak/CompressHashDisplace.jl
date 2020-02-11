using Documenter, CompressHashDisplace

makedocs(;
    modules=[CompressHashDisplace],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/Arkoniak/CompressHashDisplace.jl/blob/{commit}{path}#L{line}",
    sitename="CompressHashDisplace",
    authors="Andrey Oskin",
)

deploydocs(;
    repo="github.com/Arkoniak/CompressHashDisplace.jl",
)
