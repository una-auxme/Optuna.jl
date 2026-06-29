#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    suggest_int(
        trial::Trial,
        name::String,
        low::T,
        high::T;
        step::T=1,
        log::Bool=false
    ) where {T<:Signed}

Suggest an integer value for the given parameter name within the specified range.
For further information see the [suggest_int](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.trial.Trial.html#optuna.trial.Trial.suggest_int) in the Optuna python documentation.


## Arguments
- `trial::Trial`: The trial to suggest the parameter for. (see [Trial](@ref))
- `name::String`: The name of the parameter to suggest.
- `low::T`: The lower bound of the range (inclusive).
- `high::T`: The upper bound of the range (inclusive).

## Keyword Arguments
- `step::T=1`: The step size for the range. The suggested value will be a multiple of `step` away from `low`.
- `log::Bool=false`: If `true`, the range will be sampled on a logarithmic scale. (

## Returns
- `T`: Suggested integer value.
"""
function suggest_int(
    trial::Union{Trial{false},FixedTrial{false}},
    name::String,
    low::T,
    high::T;
    step::T=1,
    log::Bool=false,
) where {T<:Signed}
    @assert !(step != 1 && log) "The parameters `step` and `log` cannot be used " *
        "at the same time when suggesting an integer."
    return pyconvert(T, trial.trial.suggest_int(name, low, high; step=step, log=log))
end
function suggest_int(
    trial::Union{Trial{true},FixedTrial{true}},
    name::String,
    low::T,
    high::T;
    step::T=1,
    log::Bool=false,
) where {T<:Signed}
    @assert !(step != 1 && log) "The parameters `step` and `log` cannot be used " *
        "at the same time when suggesting an integer."
    thread_safe() do
        return pyconvert(T, trial.trial.suggest_int(name, low, high; step=step, log=log))
    end
end

"""
    is_frozen(trial::Trial)

Check if the given trial wraps an Optuna frozen trial.
"""
function is_frozen(trial::Trial{false})
    return pyconvert(Bool, PythonCall.pytype(trial.trial) == optuna.trial.FrozenTrial)
end
function is_frozen(trial::Trial{true})
    thread_safe() do
        return pyconvert(Bool, PythonCall.pytype(trial.trial) == optuna.trial.FrozenTrial)
    end
end

"""
    suggest_float(
        trial::Trial,
        name::String,
        low::T,
        high::T;
        step::Union{Nothing,T}=nothing,
        log::Bool=false,
    ) where {T<:AbstractFloat}

Suggest a float value for the given parameter name within the specified range.
For further information see the [suggest_float](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.trial.Trial.html#optuna.trial.Trial.suggest_float) in the Optuna python documentation.

## Arguments
- `trial::Trial`: The trial to suggest the parameter for. (see [Trial](@ref))
- `name::String`: The name of the parameter to suggest.
- `low::T`: The lower bound of the range (inclusive).
- `high::T`: The upper bound of the range (inclusive).

## Keyword Arguments
- `step::Union{Nothing,T}=nothing`: A step of discretization.
- `log::Bool=false`: If `true`, the range will be sampled on a logarithmic scale. (

## Returns
- `Float64`: Suggested float value.
"""
function suggest_float(
    trial::Union{Trial,FixedTrial},
    name::String,
    low::T,
    high::T;
    step::Union{Nothing,T}=nothing,
    log::Bool=false,
) where {T<:AbstractFloat}
    @warn "Converting to Float64, because that´s what Optuna uses internally. If you need other Float-Types you need to handle conversion after using `suggest_float`." maxlog =
        5
    return suggest_float(
        trial,
        name,
        Float64(low),
        Float64(high);
        step=convert(Union{Nothing,Float64}, step),
        log=log,
    )
end

function suggest_float(
    trial::Union{Trial{false},FixedTrial{false}},
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
    trial::Union{Trial{true},FixedTrial{true}},
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
    suggest_categorical(
        trial::Trial,
        name::String,
        choices::Union{Vector{T},Tuple{Vararg{T}}}
    ) where {T<:Union{Bool,Int,AbstractFloat,String}}

Suggest a categorical value for the given parameter name from the specified choices.
For further information see the [suggest_categorical](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.trial.Trial.html#optuna.trial.Trial.suggest_categorical) in the Optuna python documentation.

## Arguments
- `trial::Trial`: The trial to suggest the parameter for. (see [Trial](@ref))
- `name::String`: The name of the parameter to suggest.
- `choices::Union{Vector{T},Tuple{Vararg{T}}}`: The choices to suggest from.

## Returns
- `T`: Suggested categorical value.
"""
function suggest_categorical(
    trial::Trial{false}, name::String, choices::Union{Vector{T},Tuple{Vararg{T}}}
) where {T<:Union{Bool,Int,AbstractFloat,String}}
    return pyconvert(T, trial.trial.suggest_categorical(name, choices))
end
function suggest_categorical(
    trial::Trial{true}, name::String, choices::Union{Vector{T},Tuple{Vararg{T}}}
) where {T<:Union{Bool,Int,AbstractFloat,String}}
    thread_safe() do
        return pyconvert(T, trial.trial.suggest_categorical(name, choices))
    end
end
function suggest_categorical(
    trial::FixedTrial{false}, name::String, choices::Union{Vector{T},Tuple{Vararg{T}}}
) where {T<:Union{Bool,Int,AbstractFloat,String}}
    return pyconvert(T, trial.trial.suggest_categorical(name, choices))
end
function suggest_categorical(
    trial::FixedTrial{true}, name::String, choices::Union{Vector{T},Tuple{Vararg{T}}}
) where {T<:Union{Bool,Int,AbstractFloat,String}}
    thread_safe() do
        return pyconvert(T, trial.trial.suggest_categorical(name, choices))
    end
end

"""
    suggest_categorical(
        trial::Trial,
        name::String,
        choices::Union{Vector{T},Tuple{Vararg{T}}}
    ) where {T}

Suggest a categorical value for the given parameter name from the specified choices.
For further information see the [suggest_categorical](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.trial.Trial.html#optuna.trial.Trial.suggest_categorical) in the Optuna python documentation.

## Arguments
- `trial::Trial`: The trial to suggest the parameter for. (see [Trial](@ref))
- `name::String`: The name of the parameter to suggest.
- `choices::Union{Vector{T},Tuple{Vararg{T}}}`: The choices to suggest from.

## Returns
- `T`: Suggested categorical value.
"""
function suggest_categorical(
    trial::Trial{false}, name::String, choices::Union{Vector{T},Tuple{Vararg{T}}}
) where {T}
    return _suggest_categorical(trial, name, choices)
end
function suggest_categorical(
    trial::Trial{true}, name::String, choices::Union{Vector{T},Tuple{Vararg{T}}}
) where {T}
    thread_safe() do
        return _suggest_categorical(trial, name, choices)
    end
end
function suggest_categorical(
    trial::FixedTrial{false}, name::String, choices::Union{Vector{T},Tuple{Vararg{T}}}
) where {T}
    return _suggest_fixed_categorical(trial, name, choices)
end
function suggest_categorical(
    trial::FixedTrial{true}, name::String, choices::Union{Vector{T},Tuple{Vararg{T}}}
) where {T}
    thread_safe() do
        return _suggest_fixed_categorical(trial, name, choices)
    end
end

function _categorical_choice_key(i::Integer, choice)
    return "$i|$choice"
end
function _suggest_categorical(
    trial::Trial, name::String, choices::Union{Vector{T},Tuple{Vararg{T}}}
) where {T}
    choices_str = [_categorical_choice_key(i, v) for (i, v) in enumerate(choices)]
    choice = pyconvert(String, trial.trial.suggest_categorical(name, choices_str))
    choice_idx = parse(Int, split(choice, '|')[1])
    return choices[choice_idx]
end
function _suggest_fixed_categorical(
    trial::FixedTrial, name::String, choices::Union{Vector{T},Tuple{Vararg{T}}}
) where {T}
    haskey(trial.params, name) ||
        throw(ArgumentError("FixedTrial does not contain parameter `$name`."))
    value = trial.params[name]
    for (i, choice) in enumerate(choices)
        choice == value && return choice
        value isa AbstractString &&
            value == _categorical_choice_key(i, choice) &&
            return choice
    end
    throw(ArgumentError("FixedTrial parameter `$name` is not one of the provided choices."))
end

"""
    report(
        trial::Trial,
        value::AbstractFloat,
        step::Int
    )

Report an intermediate value for the given trial at a specific step.
For further information see the [report](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.trial.Trial.html#optuna.trial.Trial.report) in the Optuna python documentation.

## Arguments
- `trial::Trial`: The trial to report the value for. (see [Trial](@ref))
- `value::AbstractFloat`: The intermediate value to report.
- `step::Int`: The step at which the value is reported.
"""
function report(
    trial::Union{Trial{false},FixedTrial{false}}, value::AbstractFloat, step::Int
)
    return trial.trial.report(value; step=step)
end
function report(trial::Union{Trial{true},FixedTrial{true}}, value::AbstractFloat, step::Int)
    thread_safe() do
        return trial.trial.report(value; step=step)
    end
end

"""
    should_prune(
        trial::Trial
    )

Check if the given trial should be pruned based on the pruner's decision.
For further information see the [should_prune](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.trial.Trial.html#optuna.trial.Trial.should_prune) in the Optuna python documentation.

## Arguments
- `trial::Trial`: The trial to check for pruning. (see [Trial](@ref))

## Returns
- `Bool`: `true` if the trial should be pruned, `false` otherwise.
"""
function should_prune(trial::Union{Trial{false},FixedTrial{false}})
    return Bool(trial.trial.should_prune())
end
function should_prune(trial::Union{Trial{true},FixedTrial{true}})
    thread_safe() do
        return Bool(trial.trial.should_prune())
    end
end

"""
    set_user_attr(
        trial::Trial,
        key::String,
        value,
    )

Set a user attribute on the given trial.
For further information see the [set_user_attr](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.trial.Trial.html#optuna.trial.Trial.set_user_attr) in the Optuna python documentation.

## Arguments
- `trial::Trial`: The trial to set the user attribute on. (see [Trial](@ref))
- `key::String`: The user attribute key.
- `value`: The user attribute value.
"""
function set_user_attr(trial::Trial{false}, key::String, value)
    return trial.trial.set_user_attr(key, value)
end
function set_user_attr(trial::Trial{true}, key::String, value)
    thread_safe() do
        return trial.trial.set_user_attr(key, value)
    end
end
