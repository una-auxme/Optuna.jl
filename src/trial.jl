#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

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
function suggest_int(
    trial::Trial{false}, name::String, low::T, high::T; step::T=1, log::Bool=false
) where {T<:Signed}
    @assert !(step != 1 && log) "The parameters `step` and `log` cannot be used " *
        "at the same time when suggesting an integer."
    return pyconvert(T, trial.trial.suggest_int(name, low, high; step=step, log=log))
end
function suggest_int(
    trial::Trial{true}, name::String, low::T, high::T; step::T=1, log::Bool=false
) where {T<:Signed}
    @assert !(step != 1 && log) "The parameters `step` and `log` cannot be used " *
        "at the same time when suggesting an integer."
    thread_safe() do
        return pyconvert(T, trial.trial.suggest_int(name, low, high; step=step, log=log))
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
- `Float64`: Suggested float value.
"""
function suggest_float(
    trial::Trial,
    name::String,
    low::T,
    high::T;
    step::Union{Nothing,T}=nothing,
    log::Bool=false,
) where {T<:AbstractFloat}
    @warn "Float Types other than Float64 will be converted to Float64, because that´s what Optuna uses internally. If you need other Float-Types you need to handle conversion after using `suggest_float`." maxlog =
        5
    return suggest_float(
        trial, name, Float64(low), Float64(high), convert(Union{Nothing,Float64}, step), log
    )
end

function suggest_float(
    trial::Trial{false},
    name::String,
    low::Float64,
    high::Float64;
    step::Union{Nothing,Float64}=nothing,
    log::Bool=false,
)
    @assert !(!isnothing(step) && log) "The parameters `step` and `log` cannot be used " *
        "at the same time when suggesting a float."
    return pyconvert(
        Float64, trial.trial.suggest_float(name, low, high; step=step, log=log)
    )
end

function suggest_float(
    trial::Trial{true},
    name::String,
    low::Float64,
    high::Float64;
    step::Union{Nothing,Float64}=nothing,
    log::Bool=false,
)
    @assert !(!isnothing(step) && log) "The parameters `step` and `log` cannot be used " *
        "at the same time when suggesting a float."
    thread_safe() do
        return pyconvert(
            Float64, trial.trial.suggest_float(name, low, high; step=step, log=log)
        )
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
