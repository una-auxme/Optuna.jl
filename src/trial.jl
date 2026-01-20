#
# Copyright (c) 2026 Julian Trommer
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

struct Trial
    trial::Any
end

function suggest_int(trial::Trial, name::String, low::T, high::T) where {T<:Signed}
    pyconvert(T, trial.trial.suggest_int(name, low, high))
end

function suggest_float(trial::Trial, name::String, low::T, high::T) where {T<:AbstractFloat}
    pyconvert(T, trial.trial.suggest_float(name, low, high))
end

function suggest_categorical(
    trial::Trial, name::String, choices::Vector{T}
) where {T<:Union{Bool,Int,AbstractFloat,String}}
    pyconvert(T, trial.trial.suggest_categorical(name, choices))
end

function report(trial::Trial, value::AbstractFloat, step::Int)
    trial.trial.report(value; step=step)
end

function should_prune(trial::Trial)
    return Bool(trial.trial.should_prune())
end
