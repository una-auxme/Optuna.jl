#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Pkg: Pkg
Pkg.develop(; path=joinpath(@__DIR__, "../../Optuna.jl"))
using Documenter, Optuna

makedocs(;
    sitename="Optuna.jl",
    format=Documenter.HTML(; sidebar_sitename=false, edit_link=nothing),
    authors="Julian Trommer, and contributors.",
    modules=[Optuna],
    checkdocs=:exports,
    linkcheck=false,
    pages=["Home" => "index.md", "API Reference" => "api.md"],
)

deploydocs(; repo="github.com/una-auxme/Optuna.jl.git", devbranch="main")
