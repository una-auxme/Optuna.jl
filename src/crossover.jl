#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    UniformCrossover(
        swapping_prob::Float64=0.5
    )

Select each parameter with equal probability from the two parent individuals. 
For further information see the [UniformCrossover](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.nsgaii.UniformCrossover.html) in the Optuna python documentation.

## Arguments
- `swapping_prob::Float64=0.5`: Probability of swapping each parameter of the parents during crossover.
"""
struct UniformCrossover <: BaseCrossover
    crossover::Any

    function UniformCrossover(swapping_prob::Float64=0.5)
        crossover = optuna.samplers.nsgaii.UniformCrossover(swapping_prob)
        return new(crossover)
    end
end

"""
    BLXAlphaCrossover(
        alpha::Float64=0.5
    )

Uniformly samples child individuals from the hyper-rectangles created by the two parent individuals.
For further information see the [BLXAlphaCrossover](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.nsgaii.BLXAlphaCrossover.html) in the Optuna python documentation.

## Arguments
- `alpha::Float64=0.5`: Parametrizes blend operation.
"""
struct BLXAlphaCrossover <: BaseCrossover
    crossover::Any

    function BLXAlphaCrossover(alpha::Float64=0.5)
        crossover = optuna.samplers.nsgaii.BLXAlphaCrossover(alpha)
        return new(crossover)
    end
end

"""
    SPXCrossover(
        epsilon::Union{Nothing,Float64}=nothing
    )

Uniformly samples child individuals from within a single simplex that is similar to the simplex produced by the parent individual.
For further information see the [SPXCrossover](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.nsgaii.SPXCrossover.html) in the Optuna python documentation.

## Arguments
- `epsilon::Union{Nothing,Float64}=nothing`: Expansion rate. If not specified, defaults to sqrt(len(search_space) + 2).
"""
struct SPXCrossover <: BaseCrossover
    crossover::Any

    function SPXCrossover(epsilon::Union{Nothing,Float64}=nothing)
        crossover = optuna.samplers.nsgaii.SPXCrossover(epsilon)
        return new(crossover)
    end
end

"""
    SBXCrossover(
        eta::Union{Nothing,Float64}=nothing,
        uniform_crossover_prob::Float64=0.5,
        use_child_gene_prob::Float64=0.5,
    )

Uniformly samples child individuals from within a single simplex that is similar to the simplex produced by the parent individual.
For further information see the [SBXCrossover](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.nsgaii.SBXCrossover.html) in the Optuna python documentation.

## Arguments
- `eta::Union{Nothing,Float64}=nothing`: Distribution index. A small value of `eta` allows distant solutions to be selected as children solutions. If not specified, takes default value of 2 for single objective functions and 20 for multi objective.
- `uniform_crossover_prob::Float64=0.5`: `uniform_crossover_prob` is the probability of uniform crossover between two individuals selected as candidate child individuals. This argument is whether or not two individuals are crossover to make one child individual. If the `uniform_crossover_prob` exceeds 0.5, the result is equivalent to `1-uniform_crossover_prob`, because it returns one of the two individuals of the crossover result. If not specified, takes default value of 0.5. The range of values is [0.0, 1.0].
- `use_child_gene_prob::Float64=0.5`: `use_child_gene_prob` is the probability of using the value of the generated child variable rather than the value of the parent. This probability is applied to each variable individually. where `1-use_child_gene_prob` is the probability of using the parent’s values as it is. If not specified, takes default value of 0.5. The range of values is (0.0, 1.0].
"""
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

"""
    VSBXCrossover(
        eta::Union{Nothing,Float64}=nothing,
        uniform_crossover_prob::Float64=0.5,
        use_child_gene_prob::Float64=0.5,
    )

vSBX generates child individuals without excluding any region of the parameter space, while maintaining the excellent properties of SBX.
For further information see the [VSBXCrossover](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.nsgaii.VSBXCrossover.html) in the Optuna python documentation.

## Arguments
- `eta::Union{Nothing,Float64}=nothing`: Distribution index. A small value of `eta` allows distant solutions to be selected as children solutions. If not specified, takes default value of 2 for single objective functions and 20 for multi objective.
- `uniform_crossover_prob::Float64=0.5`: `uniform_crossover_prob` is the probability of uniform crossover between two individuals selected as candidate child individuals. This argument is whether or not two individuals are crossover to make one child individual. If the `uniform_crossover_prob` exceeds 0.5, the result is equivalent to `1-uniform_crossover_prob`, because it returns one of the two individuals of the crossover result. If not specified, takes default value of 0.5. The range of values is [0.0, 1.0].
- `use_child_gene_prob::Float64=0.5`: `use_child_gene_prob` is the probability of using the value of the generated child variable rather than the value of the parent. This probability is applied to each variable individually. where `1-use_child_gene_prob` is the probability of using the parent’s values as it is. If not specified, takes default value of 0.5. The range of values is (0.0, 1.0].
"""
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

"""
    UNDXCrossover(
        sigma_xi::Float64=0.5, 
        sigma_eta::Union{Nothing,Float64}=nothing
    )

Generates child individuals from the three parents using a multivariate normal distribution.
For further information see the [UNDXCrossover](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.nsgaii.UNDXCrossover.html) in the Optuna python documentation.

## Arguments
- `sigma_xi::Float64=0.5`: Parametrizes normal distribution from which `xi` is drawn.
- `sigma_eta::Union{Nothing,Float64}=nothing`: Parametrizes normal distribution from which etas are drawn. If not specified, defaults to 0.35 / sqrt(len(search_space)).
"""
struct UNDXCrossover <: BaseCrossover
    crossover::Any

    function UNDXCrossover(sigma_xi::Float64=0.5, sigma_eta::Union{Nothing,Float64}=nothing)
        crossover = optuna.samplers.nsgaii.UNDXCrossover(sigma_xi, sigma_eta)
        return new(crossover)
    end
end
