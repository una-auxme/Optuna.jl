#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# Track which parameters have already been warned about for Float32 bounds
const _warned_float32_params = Set{String}()

"""
    Trial(trial)

Trial is a data structure wrapper for an Optuna trial.
"""
struct Trial{multithreading}
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
- `Int`: Suggested integer value. Always returns Int to match Optuna's internal representation.

## Notes
- Optuna uses Python integers internally. This function always returns Int 
  to maintain consistency with `best_params()`.
"""
function suggest_int(
    trial::Trial{false}, name::String, low::T, high::T; step::Integer=1, log::Bool=false
) where {T<:Signed}
    @assert !(step != 1 && log) "The parameters `step` and `log` cannot be used " *
        "at the same time when suggesting an integer."
    return pyconvert(Int, trial.trial.suggest_int(name, low, high; step=step, log=log))
end
function suggest_int(
    trial::Trial{true}, name::String, low::T, high::T; step::Integer=1, log::Bool=false
) where {T<:Signed}
    @assert !(step != 1 && log) "The parameters `step` and `log` cannot be used " *
        "at the same time when suggesting an integer."
    thread_safe() do
        return pyconvert(Int, trial.trial.suggest_int(name, low, high; step=step, log=log))
    end
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
- `Float64`: Suggested float value. Always returns Float64 to match Optuna's internal representation.

## Notes
- Optuna uses Python floats (Float64) internally. This function always returns Float64 
  to maintain consistency with `best_params()`.
- A warning is issued if Float32 bounds are provided, as they will be converted to Float64.
"""
function suggest_float(
    trial::Trial{false},
    name::String,
    low::T,
    high::T;
    step::Union{Nothing,Real}=nothing,
    log::Bool=false,
) where {T<:AbstractFloat}
    @assert !(!isnothing(step) && log) "The parameters `step` and `log` cannot be used " *
        "at the same time when suggesting a float."
    if T == Float32 && !(name in _warned_float32_params)
        @warn "Float32 bounds provided to suggest_float for parameter '$name'. Return type will be Float64 to match Optuna's internal representation."
        push!(_warned_float32_params, name)
    end
    return pyconvert(Float64, trial.trial.suggest_float(name, low, high; step=step, log=log))
end
function suggest_float(
    trial::Trial{true},
    name::String,
    low::T,
    high::T;
    step::Union{Nothing,Real}=nothing,
    log::Bool=false,
) where {T<:AbstractFloat}
    @assert !(!isnothing(step) && log) "The parameters `step` and `log` cannot be used " *
        "at the same time when suggesting a float."
    if T == Float32 && !(name in _warned_float32_params)
        @warn "Float32 bounds provided to suggest_float for parameter '$name'. Return type will be Float64 to match Optuna's internal representation."
        push!(_warned_float32_params, name)
    end
    thread_safe() do
        return pyconvert(Float64, trial.trial.suggest_float(name, low, high; step=step, log=log))
    end
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
    trial::Trial{false}, name::String, choices::Vector{T}
) where {T<:Union{Bool,Int,AbstractFloat,String}}
    return pyconvert(T, trial.trial.suggest_categorical(name, choices))
end
function suggest_categorical(
    trial::Trial{true}, name::String, choices::Vector{T}
) where {T<:Union{Bool,Int,AbstractFloat,String}}
    thread_safe() do
        return pyconvert(T, trial.trial.suggest_categorical(name, choices))
    end
end

"""
    report(trial::Trial, value::AbstractFloat, step::Int)

Report an intermediate value for the given trial at a specific step.

## Arguments
- `trial::Trial`: The trial to report the value for. (see [Trial](@ref))
- `value::AbstractFloat`: The intermediate value to report.
- `step::Int`: The step at which the value is reported.
"""
function report(trial::Trial{false}, value::AbstractFloat, step::Int)
    return trial.trial.report(value; step=step)
end
function report(trial::Trial{true}, value::AbstractFloat, step::Int)
    thread_safe() do
        return trial.trial.report(value; step=step)
    end
end

"""
    should_prune(trial::Trial)

Check if the given trial should be pruned based on the pruner's decision.

## Arguments
- `trial::Trial`: The trial to check for pruning. (see [Trial](@ref))

## Returns
- `Bool`: `true` if the trial should be pruned, `false` otherwise.
"""
function should_prune(trial::Trial{false})
    return Bool(trial.trial.should_prune())
end
function should_prune(trial::Trial{true})
    thread_safe() do
        return Bool(trial.trial.should_prune())
    end
end
