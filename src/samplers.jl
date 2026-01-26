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

    function RandomSampler(seed=nothing::Union{Nothing,UInt32})
        sampler = optuna.samplers.RandomSampler(
            isnothing(seed) ? PythonCall.pybuiltins.None : pyconvert(UInt32, seed)
        )
        return new(sampler)
    end
end
