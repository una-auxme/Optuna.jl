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

    function RandomSampler(seed::Union{Nothing,UInt32}=nothing)
        sampler = optuna.samplers.RandomSampler(
            isnothing(seed) ? PythonCall.pybuiltins.None : pyconvert(UInt32, seed)
        )
        return new(sampler)
    end
end

"""
    TPESampler(; ...)

Sampler using TPE (Tree-structured Parzen Estimator) algorithm.
For further information see the (Optuna documentation)[https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.TPESampler.html].

## Keywords
- `consider_prior::Bool` (default=true).
- `prior_weight::Int32` (default=1.0).
- `consider_magic_clip::Bool` (default=true).
- `consider_endpoints::Bool` (default=false).
- `n_startup_trials::Int32` (default=10).
- `n_ei_candidates::Int32` (default=24).
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
        prior_weight::Int32=1.0,
        consider_magic_clip::Bool=true,
        consider_endpoints::Bool=false,
        n_startup_trials::Int32=10,
        n_ei_candidates::Int32=24,
        seed::Union{Nothing,UInt32}=nothing,
        multivariate::Bool=false,
        group::Bool=false,
        warn_independent_sampling::Bool=true,
        constant_liar::Bool=false,
    )
        sampler = optuna.samplers.TPESampler(;
            consider_prior=pyconvert(Bool, consider_prior),
            prior_weight=pyconvert(Float64, prior_weight),
            consider_magic_clip=pyconvert(Bool, consider_magic_clip),
            consider_endpoints=pyconvert(Bool, consider_endpoints),
            n_startup_trials=pyconvert(Int32, n_startup_trials),
            n_ei_candidates=pyconvert(Int32, n_ei_candidates),
            seed=isnothing(seed) ? PythonCall.pybuiltins.None : pyconvert(UInt32, seed),
            multivariate=pyconvert(Bool, multivariate),
            group=pyconvert(Bool, group),
            warn_independent_sampling=pyconvert(Bool, warn_independent_sampling),
            constant_liar=pyconvert(Bool, constant_liar),
        )
        return new(sampler)
    end
end
