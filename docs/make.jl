using Documenter, SIMDscan

DocMeta.setdocmeta!(SIMDscan, :DocTestSetup, :(using SIMDscan); recursive=true)

makedocs(;
         modules=[SIMDscan],
         authors="Paul Schrimpf <paul.schrimpf@ubc.ca> and contributors",
         repo=Remotes.GitHub("schrimpf","SIMDscan.jl"),
         sitename="SIMDscan.jl",
         format=Documenter.HTML(;
                                prettyurls=get(ENV, "CI", "false") == "true",
                                edit_link="main",
                                assets=String[],
                                ),
         pages=[
           "Home" => "index.md",
           "Benchmarks" => "benchmarks.md"
         ]
         )

deploydocs(;
           repo="github.com/schrimpf/SIMDscan.jl",
           devbranch="main"
)
