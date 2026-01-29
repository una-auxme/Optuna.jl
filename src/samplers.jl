#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    BaseSampler is an abstract type for samplers.
"""
abstract type BaseSampler end

"""
    RandomSampler(seed=nothing::Union{Nothing,Integer})

An independent sampler that samples randomly.
For further information see the [RandomSampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.RandomSampler.html#optuna-samplers-randomsampler) in the Optuna python documentation.

## Arguments
- `seed::Union{Nothing,Integer}=nothing`: Seed for the random number generator.
"""
struct RandomSampler <: BaseSampler
    sampler::Any

    function RandomSampler(seed::Union{Nothing,Integer}=nothing)
        sampler = optuna.samplers.RandomSampler(convert_seed(seed))
        return new(sampler)
    end
end

"""
    TPESampler(; ...)

Sampler using TPE (Tree-structured Parzen Estimator) algorithm.
For further information see the [TPESampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.TPESampler.html#optuna-samplers-tpesampler) in the Optuna python documentation.

## Keywords
- `consider_prior::Bool` (default=true).
- `prior_weight::Float64` (default=1.0).
- `consider_magic_clip::Bool` (default=true).
- `consider_endpoints::Bool` (default=false).
- `n_startup_trials::Integer` (default=10).
- `n_ei_candidates::Integer` (default=24).
- `seed::Union{Nothing,Integer}`: Seed for the random number generator (default=nothing).
- `multivariate::Bool` (default=false).
- `group::Bool` (default=false).
- `warn_independent_sampling::Bool` (default=true).
- `constant_liar::Bool` (default=false).
"""
struct TPESampler <: BaseSampler
    sampler::Any

    # ToDo: Add kwargs gamma=<function default_gamma>, weights=<function default_weights>, 
    # ToDo: Add kwarf functions constraints_func=nothing, categorical_distance_func=nothing,
    function TPESampler(;
        consider_prior::Bool=true,
        prior_weight::Float64=1.0,
        consider_magic_clip::Bool=true,
        consider_endpoints::Bool=false,
        n_startup_trials::Int=10,
        n_ei_candidates::Int=24,
        seed::Union{Nothing,Integer}=nothing,
        multivariate::Bool=false,
        group::Bool=false,
        warn_independent_sampling::Bool=true,
        constant_liar::Bool=false,
    )
        sampler = optuna.samplers.TPESampler(;
            consider_prior=consider_prior,
            prior_weight=prior_weight,
            consider_magic_clip=consider_magic_clip,
            consider_endpoints=consider_endpoints,
            n_startup_trials=n_startup_trials,
            n_ei_candidates=n_ei_candidates,
            seed=convert_seed(seed),
            multivariate=multivariate,
            group=group,
            warn_independent_sampling=warn_independent_sampling,
            constant_liar=constant_liar,
        )
        return new(sampler)
    end
end

"""
    GPSampler(; ...)

Sampler using Gaussian process-based Bayesian optimization.
For further information and keywords see the [GPSampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.GPSampler.html#optuna-samplers-gpsampler) in the Optuna python documentation.
"""
struct GPSampler <: BaseSampler
    sampler::Any

    # ToDo: Add constraints_func=None, independent_sampler=nothing,
    function GPSampler(;
        seed::Union{Nothing,Integer}=nothing,
        n_startup_trials::Int=10,
        deterministic_objective::Bool=false,
        warn_independent_sampling::Bool=true,
    )
        sampler = optuna.samplers.GPSampler(;
            seed=convert_seed(seed),
            n_startup_trials=n_startup_trials,
            deterministic_objective=deterministic_objective,
            warn_independent_sampling=warn_independent_sampling,
        )
        return new(sampler)
    end
end

"""
    CmaEsSampler()

A sampler using cmaes as the backend.

For further information see the [CmaEsSampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.CmaEsSampler.html#optuna-samplers-cmaessampler) in the Optuna python documentation.
"""
struct CmaEsSampler <: BaseSampler
    sampler::Any

    # ToDo: Implement!
    function CmaEsSampler()
        @assert false "`CmaEsSampler` not implemented yet. Please open an issue or PR."
        return new(sampler)
    end
end

"""
    NSGAIISampler()

Multi-objective sampler using the NSGA-II algorithm.

For further information see the [NSGAIISampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.NSGAIISampler.html#optuna-samplers-nsgaiisampler) in the Optuna python documentation.
"""
struct NSGAIISampler <: BaseSampler
    sampler::Any

    # ToDo: Implement!
    function NSGAIISampler()
        @assert false "`NSGAIISampler` not implemented yet. Please open an issue or PR."
        return new(sampler)
    end
end

"""
    NSGAIIISampler()

Multi-objective sampler using the NSGA-III algorithm.

For further information see the [NSGAIIISampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.NSGAIIISampler.html#optuna-samplers-nsgaiiisampler) in the Optuna python documentation.
"""
struct NSGAIIISampler <: BaseSampler
    sampler::Any

    # ToDo: Implement!
    function NSGAIIISampler()
        @assert false "`NSGAIIISampler` not implemented yet. Please open an issue or PR."
        return new(sampler)
    end
end

"""
    GridSampler(search_space, seed)

Sampler using grid search.
For further information see the [GridSampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.GridSampler.html#optuna-samplers-gridsampler) in the Optuna python documentation.

## Arguments
- `search_space::NamedTuple`
- `seed::Union{Nothing,Integer}=nothing`: Seed for the random number generator.
"""
struct GridSampler <: BaseSampler
    sampler::Any

    function GridSampler(search_space::Any, seed::Union{Nothing,Integer}=nothing)
        sampler = optuna.samplers.GridSampler(PyDict(search_space), convert_seed(seed))
        return new(sampler)
    end
end

"""
    QMCSampler(; ...)

A Quasi Monte Carlo Sampler that generates low-discrepancy sequences.
For further information see the [QMCSampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.QMCSampler.html#optuna-samplers-qmcsampler) in the Optuna python documentation.
"""
struct QMCSampler <: BaseSampler
    sampler::Any

    # ToDo: Implement keyword `independent_sampler=None`
    function QMCSampler(;
        qmc_type::String="sobol",
        scramble::Bool=false,
        seed::Union{Nothing,Integer}=nothing,
        warn_asynchronous_seeding::Bool=true,
        warn_independent_sampling::Bool=true,
    )
        sampler = optuna.samplers.QMCSampler(;
            qmc_type=qmc_type,
            scramble=scramble,
            seed=convert_seed(seed),
            warn_asynchronous_seeding=warn_asynchronous_seeding,
            warn_independent_sampling=warn_independent_sampling,
        )

        return new(sampler)
    end
end

"""
    BruteForceSampler(seed, avoid_premature_stop)

Sampler using brute force.

This sampler performs exhaustive search on the defined search space.
For further information see the [BruteForceSampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.BruteForceSampler.html#optuna-samplers-bruteforcesampler) in the Optuna python documentation.
"""
struct BruteForceSampler <: BaseSampler
    sampler::Any

    function BruteForceSampler(
        seed::Union{Nothing,Integer}=nothing, avoid_premature_stop::Bool=false
    )
        sampler = optuna.samplers.BruteForceSampler(
            convert_seed(seed), avoid_premature_stop
        )

        return new(sampler)
    end
end

"""
    PartialFixedSampler(fixed_params, base_sampler)

Sampler with partially fixed parameters.

For further information see the [PartialFixedSampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.PartialFixedSampler.html#optuna-samplers-partialfixedsampler) in the Optuna python documentation.
"""
struct PartialFixedSampler <: BaseSampler
    sampler::Any

    function PartialFixedSampler(fixed_params::Dict, base_sampler::BaseSampler)
        sampler = optuna.samplers.PartialFixedSampler(
            PyDict(fixed_params), base_sampler.sampler
        )

        return new(sampler)
    end
end
