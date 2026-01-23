#
# Copyright (c) 2026 Julian Trommer
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    optimize(study::Study, objective::Function, params::NamedTuple; n_trials=100::Int)

Optimize the objective function by choosing a suitable set of hyperparameter values from the given params.

Uses the sampler of the study which implements the task of value suggestion based on a specified distribution. For the available samplers see [Sampler](@ref).

If the objective function returns `nothing`, the trial is pruned.

## Arguments
- `study::Study`: [Study](@ref) that should be optimized.
- `objective::Function`: Function that takes a trial and returns a score.
- `params::NamedTuple`: Named tuple of parameters to optimize.

## Keyword Arguments
- `n_trials::Int`: Number of trials to run.

## Returns
- `Study`: The optimized study. [Study](@ref)
"""
function optimize(study::Study, objective::Function, params::NamedTuple; n_trials=100::Int)
    for _ in 1:n_trials
        trial = ask(study)

        args_fn = Dict{Symbol,Any}()
        for k in keys(params)
            v = params[k]
            if v[1] isa Signed
                args_fn[k] = suggest_int(trial, string(k), v[1], v[2])
            elseif v[1] isa AbstractFloat
                args_fn[k] = suggest_float(trial, string(k), v[1], v[2])
            elseif v isa Vector
                args_fn[k] = suggest_categorical(trial, string(k), v)
            else
                error(
                    "Unsupported parameter type for key: $k => value $(typeof(v)). Possible types are Int, AbstractFloat, and Vector.",
                )
            end
        end

        score = objective(trial; args_fn...)
        if isnothing(score)
            tell(study, trial; prune=true)
        else
            tell(study, trial, score)
        end
    end
    return study
end
