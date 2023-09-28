using SIMDscan
using Documenter

DocMeta.setdocmeta!(SIMDscan, :DocTestSetup, :(using SIMDscan); recursive=true)

makedocs(;
    modules=[SIMDscan],
    authors="Paul Schrimpf <paul.schrimpf@gmail.com> and contributors",
    repo="https://github.com/schrimpf/SIMDscan.jl/blob/{commit}{path}#{line}",
    sitename="SIMDscan.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://schrimpf.github.io/SIMDscan.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/schrimpf/SIMDscan.jl",
    devbranch="main",
)
