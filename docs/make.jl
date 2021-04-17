using Documenter, CompressHashDisplace

makedocs(;
    modules=[CompressHashDisplace],
    authors="Andrey Oskin",
    repo="https://github.com/Arkoniak/CompressHashDisplace.jl/blob/{commit}{path}#L{line}",
    sitename="CompressHashDisplace.jl",
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Arkoniak.github.io/CompressHashDisplace.jl",
        siteurl="https://github.com/Arkoniak/CompressHashDisplace.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Arkoniak/CompressHashDisplace.jl",
)
