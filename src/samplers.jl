#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

abstract type BaseSampler end

struct RandomSampler <: BaseSampler
    sampler::Any

    function RandomSampler(seed=nothing::Union{Nothing,Int})
        sampler = optuna.samplers.RandomSampler(
            isnothing(seed) ? PythonCall.pybuiltins.None : pyconvert(Int, seed)
        )
        return new(sampler)
    end
end
