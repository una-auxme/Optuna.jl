#
# Copyright (c) 2026 Julian Trommer
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    Trial is a data structure wrapper for an Optuna trial.
"""
struct Trial
    trial::Any
end

"""
    suggest_int(trial::Trial, name::String, low::T, high::T) where {T<:Signed}

Suggest an integer value for the given parameter name within the specified range.

## Arguments
- `trial::Trial`: The trial to suggest the parameter for. (see [Trial](@ref))
- `name::String`: The name of the parameter to suggest.
- `low::T`: The lower bound of the range (inclusive).
- `high::T`: The upper bound of the range (inclusive).

## Returns
- `T`: Suggested integer value.
"""
function suggest_int(trial::Trial, name::String, low::T, high::T) where {T<:Signed}
    return pyconvert(T, trial.trial.suggest_int(name, low, high))
end

"""
    suggest_float(trial::Trial, name::String, low::T, high::T) where {T<:AbstractFloat}

Suggest a float value for the given parameter name within the specified range.

## Arguments
- `trial::Trial`: The trial to suggest the parameter for. (see [Trial](@ref))
- `name::String`: The name of the parameter to suggest.
- `low::T`: The lower bound of the range (inclusive).
- `high::T`: The upper bound of the range (inclusive).

## Returns
- `T`: Suggested float value.
"""
function suggest_float(trial::Trial, name::String, low::T, high::T) where {T<:AbstractFloat}
    return pyconvert(T, trial.trial.suggest_float(name, low, high))
end

"""
    suggest_categorical(trial::Trial, name::String, choices::Vector{T}) where {T<:Union{Bool,Int,AbstractFloat,String}}

Suggest a categorical value for the given parameter name from the specified choices.

## Arguments
- `trial::Trial`: The trial to suggest the parameter for. (see [Trial](@ref))
- `name::String`: The name of the parameter to suggest.
- `low::T`: The lower bound of the range (inclusive).
- `high::T`: The upper bound of the range (inclusive).

## Returns
- `T`: Suggested integer value.
"""
function suggest_categorical(
    trial::Trial, name::String, choices::Vector{T}
) where {T<:Union{Bool,Int,AbstractFloat,String}}
    return pyconvert(T, trial.trial.suggest_categorical(name, choices))
end

"""
    report(trial::Trial, value::AbstractFloat, step::Int)

Report an intermediate value for the given trial at a specific step.

## Arguments
- `trial::Trial`: The trial to report the value for. (see [Trial](@ref))
- `value::AbstractFloat`: The intermediate value to report.
- `step::Int`: The step at which the value is reported.
"""
function report(trial::Trial, value::AbstractFloat, step::Int)
    return trial.trial.report(value; step=step)
end

"""
    should_prune(trial::Trial)

Check if the given trial should be pruned based on the pruner's decision.

## Arguments
- `trial::Trial`: The trial to check for pruning. (see [Trial](@ref))

## Returns
- `Bool`: `true` if the trial should be pruned, `false` otherwise.
"""
function should_prune(trial::Trial)
    return Bool(trial.trial.should_prune())
end
