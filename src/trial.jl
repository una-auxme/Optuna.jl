#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

struct Trial{multithreading}
    trial::Any
end

function suggest_int(trial::Trial{false}, name::String, low::T, high::T) where {T<:Signed}
    return pyconvert(T, trial.trial.suggest_int(name, low, high))
end
function suggest_int(trial::Trial{true}, name::String, low::T, high::T) where {T<:Signed}
    thread_safe() do
        return pyconvert(T, trial.trial.suggest_int(name, low, high))
    end
end

function suggest_float(
    trial::Trial{false}, name::String, low::T, high::T
) where {T<:AbstractFloat}
    return pyconvert(T, trial.trial.suggest_float(name, low, high))
end
function suggest_float(
    trial::Trial{true}, name::String, low::T, high::T
) where {T<:AbstractFloat}
    thread_safe() do
        return pyconvert(T, trial.trial.suggest_float(name, low, high))
    end
end

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

function report(trial::Trial{false}, value::AbstractFloat, step::Int)
    return trial.trial.report(value; step=step)
end
function report(trial::Trial{true}, value::AbstractFloat, step::Int)
    thread_safe() do
        return trial.trial.report(value; step=step)
    end
end

function should_prune(trial::Trial{false})
    return Bool(trial.trial.should_prune())
end
function should_prune(trial::Trial{true})
    thread_safe() do
        return Bool(trial.trial.should_prune())
    end
end
