#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
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
function optimize(
    study::Study,
    objective::Function,
    params::NamedTuple;
    n_trials=100::Int,
    verbose::Bool=false,
    n_jobs::Integer=1,
)
    @assert n_jobs > 0 "`optimize` is called with keyword `n_jobs=$(n_jobs)`, this doesn't make any sense."
    @assert n_jobs == 1 || n_jobs <= Threads.nthreads() "`optimize` is called with keyword `n_jobs=$(n_jobs)`, but process only provides $(Threads.nthreads()) threads."
    @assert n_jobs == 1 || Threads.nthreads(:interactive) == 1 "`optimize` is called with keyword `n_jobs=$(n_jobs)`, therefore we require exactly one interactive thread. The number of interactive threads is `$(Threads.nthreads(:interactive))`."

    if n_jobs > 1 && n_jobs < Threads.nthreads()
        @warn "`optimize` is called with keyword `n_jobs=$(n_jobs)`, however, $(Threads.nthreads()) are allocated. All threads will be used for calculation."
    end

    if n_jobs == 1
        return optimize_singlethreading(
            study, objective, params; n_trials=n_trials, verbose=verbose
        )
    else
        return optimize_multithreading(
            study, objective, params; n_trials=n_trials, verbose=verbose
        )
    end
end

function run_trial(study, trial, params, objective)
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

    if hasmethod(objective, (Trial, NamedTuple))
        score = objective(
            trial, NamedTuple((Symbol(key), value) for (key, value) in args_fn)
        )
    else
        score = objective(trial; args_fn...)
    end

    if isnothing(score)
        tell(study, trial; prune=true)
    else
        tell(study, trial, score)
    end
end

function optimize_singlethreading(
    study::Study,
    objective::Function,
    params::NamedTuple;
    n_trials::Int=100,
    verbose::Bool=false,
)
    for i in 1:n_trials
        if verbose
            @info "[$(Threads.threadid())] Starting trial $(i) / $(n_trials)"
        end

        trial = ask(study; multithreading=false)

        run_trial(study, trial, params, objective)
    end

    return study
end

function optimize_multithreading(
    study::Study,
    objective::Function,
    params::NamedTuple;
    n_trials=100::Int,
    verbose::Bool=false,
)
    PythonCall.GIL.unlock() do
        Threads.@threads for i in 1:n_trials
            if verbose
                @info "[$(Threads.threadid())] Starting trial $(i) / $(n_trials)"
            end

            trial = ask(study; multithreading=true)

            run_trial(study, trial, params, objective)
        end
    end

    return study
end
