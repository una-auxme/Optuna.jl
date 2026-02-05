#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#
struct UniformCrossover <: BaseCrossover
    crossover::Any

    function UniformCrossover(swapping_prob::Float64=0.5)
        crossover = optuna.samplers.nsgaii.UniformCrossover(swapping_prob)
        return new(crossover)
    end
end

struct BLXAlphaCrossover <: BaseCrossover
    crossover::Any

    function BLXAlphaCrossover(alpha::Float64=0.5)
        crossover = optuna.samplers.nsgaii.BLXAlphaCrossover(alpha)
        return new(crossover)
    end
end

struct SPXCrossover <: BaseCrossover
    crossover::Any

    function SPXCrossover(epsilon::Union{Nothing,Float64}=nothing)
        crossover = optuna.samplers.nsgaii.SPXCrossover(epsilon)
        return new(crossover)
    end
end

struct SBXCrossover <: BaseCrossover
    crossover::Any

    function SBXCrossover(
        eta::Union{Nothing,Float64}=nothing,
        uniform_crossover_prob::Float64=0.5,
        use_child_gene_prob::Float64=0.5,
    )
        crossover = optuna.samplers.nsgaii.SBXCrossover(
            eta, uniform_crossover_prob, use_child_gene_prob
        )
        return new(crossover)
    end
end

struct VSBXCrossover <: BaseCrossover
    crossover::Any

    function VSBXCrossover(
        eta::Union{Nothing,Float64}=nothing,
        uniform_crossover_prob::Float64=0.5,
        use_child_gene_prob::Float64=0.5,
    )
        crossover = optuna.samplers.nsgaii.VSBXCrossover(
            eta, uniform_crossover_prob, use_child_gene_prob
        )
        return new(crossover)
    end
end

struct UNDXCrossover <: BaseCrossover
    crossover::Any

    function UNDXCrossover(sigma_xi::Float64=0.5, sigma_eta::Union{Nothing,Float64}=nothing)
        crossover = optuna.samplers.nsgaii.UNDXCrossover(sigma_xi, sigma_eta)
        return new(crossover)
    end
end
