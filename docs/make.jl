using Documenter, SIMDscan, DocumenterCitations

DocMeta.setdocmeta!(SIMDscan, :DocTestSetup, :(using SIMDscan); recursive=true)

bib = CitationBibliography(joinpath(@__DIR__,"simd.bib"), style=:authoryear)

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
           "Benchmarks" => "benchmarks.md",
           "References" => "references.md"
         ],
         plugins=[bib]
         )

deploydocs(;
           repo="github.com/schrimpf/SIMDscan.jl",
           devbranch="main"
)
