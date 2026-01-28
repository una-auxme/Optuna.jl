#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    BaseSampler is an abstract type for samplers.
"""
abstract type BaseSampler end

"""
    RandomSampler(seed=nothing::Union{Nothing,UInt32})

An independent sampler that samples randomly

## Arguments
- `seed::Union{Nothing,UInt32}=nothing`: Seed for the random number generator.
"""
struct RandomSampler <: BaseSampler
    sampler::Any

    # Notice: UInt32 is not in line with the Python docu, but we get an error message for signed ints from Python!
    # See issue: #30
    function RandomSampler(seed::Union{Nothing,UInt32}=nothing)
        sampler = optuna.samplers.RandomSampler(convert_seed(seed))
        return new(sampler)
    end
end

"""
    TPESampler(; ...)

Sampler using TPE (Tree-structured Parzen Estimator) algorithm.
For further information see the [TPESampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.TPESampler.html) in the Optuna python documentation.

## Keywords
- `consider_prior::Bool` (default=true).
- `prior_weight::Float64` (default=1.0).
- `consider_magic_clip::Bool` (default=true).
- `consider_endpoints::Bool` (default=false).
- `n_startup_trials::Integer` (default=10).
- `n_ei_candidates::Integer` (default=24).
- `seed::Union{Nothing,UInt32}`: Seed for the random number generator (default=nothing).
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
        seed::Union{Nothing,UInt32}=nothing,
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
        seed::Union{Nothing,UInt32}=nothing,
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