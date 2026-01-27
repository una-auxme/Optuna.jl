#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Optuna
using Test

include("utils.jl")

@testset "Optuna.jl" begin
    include("pruners.jl")
    include("samplers.jl")
    include("storage.jl")
    include("artifacts.jl")
    include("trial.jl")
    include("study.jl")
    include("optimize.jl")
    include("single_step.jl")
end
