#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using CondaPkg

# These libraries are not lazy loaded by optuna
CondaPkg.add("pymysql"; version=">=1,<2")
CondaPkg.add("cryptography"; version=">=46,<47")
CondaPkg.add("redis-py"; version=">=7,<8")
CondaPkg.resolve(; force=true)

using Optuna
using Test

@testset "Optuna.jl" begin
    include("utils.jl")
    include("pruners.jl")
    include("samplers.jl")
    include("storage.jl")
    include("artifacts.jl")
    include("trial.jl")
    include("study.jl")
    include("optimize.jl")
    include("optimize_multithreading.jl")
    include("single_step.jl")
end
