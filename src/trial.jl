#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofman, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

struct Trial
    trial::Any
end

function suggest_int(trial::Trial, name::String, low::T, high::T) where {T<:Signed}
    return pyconvert(T, trial.trial.suggest_int(name, low, high))
end

function suggest_float(trial::Trial, name::String, low::T, high::T) where {T<:AbstractFloat}
    return pyconvert(T, trial.trial.suggest_float(name, low, high))
end

function suggest_categorical(
    trial::Trial, name::String, choices::Vector{T}
) where {T<:Union{Bool,Int,AbstractFloat,String}}
    return pyconvert(T, trial.trial.suggest_categorical(name, choices))
end

function report(trial::Trial, value::AbstractFloat, step::Int)
    return trial.trial.report(value; step=step)
end

function should_prune(trial::Trial)
    return Bool(trial.trial.should_prune())
end
