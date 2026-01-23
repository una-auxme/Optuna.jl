#
# Copyright (c) 2026 Julian Trommer
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    BaseSampler is an abstract type for samplers.
"""
abstract type BaseSampler end

"""
    RandomSampler(seed=nothing::Union{Nothing,Int})

An independent sampler that samples randomly

## Arguments
- `seed::Union{Nothing,Int}=nothing`: Seed for the random number generator.
"""
struct RandomSampler <: BaseSampler
    sampler::Any

    function RandomSampler(seed=nothing::Union{Nothing,Int})
        sampler = optuna.samplers.RandomSampler(
            isnothing(seed) ? PythonCall.pybuiltins.None : pyconvert(Int, seed)
        )
        return new(sampler)
    end
end
