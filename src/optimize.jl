#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    optimize(
        study::Study,
        objective::Function;
        n_trials::Int=100,
        verbose::Bool=false,
        n_jobs::Integer=1,
    )

Optimize function that checks if the optimization should be performed in a single-threaded or multi-threaded way based on the keyword argument `n_jobs` and calls the corresponding function.

Uses the sampler of the study which implements the task of value suggestion based on a specified distribution. For the available samplers see [Sampler](@ref).

If the objective function returns `nothing`, the trial is pruned.

## Arguments
- `study::Study`: [Study](@ref) that should be optimized.
- `objective::Function`: Function that takes a trial and returns a score.

## Keyword Arguments
- `n_trials::Int=100`: Number of trials to run.
- `verbose::Bool=false`: If true, print information about the optimization process.
- `n_jobs::Integer=1`: Number of threads to use for optimization. If `n_jobs > 1`, multithreading is used. Note that the number of threads allocated for the process must be greater than or equal to `n_jobs` and exactly one interactive thread must be allocated for multithreading to work. You can start Julia with n threads and an interactive thread by setting the environment variable `JULIA_NUM_THREADS=n,1` or start the Julia REPL with `-t n,1`.

## Returns
- `Study`: The optimized study. [Study](@ref)
"""
function optimize(
    study::Study,
    objective::Function;
    n_trials::Int=100,
    verbose::Bool=false,
    n_jobs::Integer=1,
)
    @assert n_jobs > 0 "`optimize` is called with keyword `n_jobs=$(n_jobs)`," *
        "this doesn't make any sense."
    @assert n_jobs == 1 || n_jobs <= Threads.nthreads() "`optimize` is called with " *
        "keyword `n_jobs=$(n_jobs)`, but process only provides $(Threads.nthreads()) threads."
    @assert n_jobs == 1 || Threads.nthreads(:interactive) == 1 "`optimize` is called " *
        "with keyword `n_jobs=$(n_jobs)`, therefore we require exactly one interactive " *
        "thread. The number of interactive threads is `$(Threads.nthreads(:interactive))`. " *
        "You can start Julia with n threads and an interactive thread by setting the " *
        "environment variable `JULIA_NUM_THREADS=n,1` or start the Julia REPL with `-t n,1`."

    if n_jobs > 1 && n_jobs < Threads.nthreads()
        @warn "`optimize` is called with keyword `n_jobs=$(n_jobs)`, however, " *
            "$(Threads.nthreads()) are allocated. All threads will be used for calculation."
    end

    if n_jobs == 1
        return optimize_singlethreading(
            study, objective; n_trials=n_trials, verbose=verbose
        )
    else
        return optimize_multithreading(study, objective; n_trials=n_trials, verbose=verbose)
    end
end

"""
    run_trial(
        study::Study,
        trial::Trial;
        objective::Function
    )

Run the objective function with the given trial. Then, report the result of the trial to the study. If the score is `nothing`, the trial is pruned.

## Arguments
- `study::Study`: [Study](@ref) to which the `trial` belongs.
- `trial::Trial`: The trial for which the parameters are suggested and the objective function is run. (see [Trial](@ref))
- `objective::Function`: Function that takes a trial and returns a score.
"""
function run_trial(study::Study, trial::Trial, objective::Function)
    score = objective(trial)

    if isnothing(score)
        tell(study, trial; prune=true)
    else
        tell(study, trial, score)
    end
end

"""
    optimize_singlethreading(
        study::Study,
        objective::Function;
        n_trials::Int=100,
        verbose::Bool=false,
    )

Optimize the objective function.

Uses the sampler of the study which implements the task of value suggestion based on a specified distribution. For the available samplers see [Sampler](@ref).

This function works in a single-threaded way and is used when the keyword argument `n_jobs` of `optimize` is set to 1.

## Arguments
- `study::Study`: [Study](@ref) to which the `trial` belongs.
- `objective::Function`: Function that takes a trial and returns a score.

## Keyword Arguments
- `n_trials::Int=100`: Number of trials to run.
- `verbose::Bool=false`: If true, print information about the optimization process.

## Returns
- `Study`: The optimized study. [Study](@ref)
"""
function optimize_singlethreading(
    study::Study, objective::Function; n_trials::Int=100, verbose::Bool=false
)
    for i in 1:n_trials
        if verbose
            @info "[$(Threads.threadid())] Starting trial $(i) / $(n_trials)"
        end

        trial = ask(study; multithreading=false)

        run_trial(study, trial, objective)
    end

    return study
end

"""
    optimize_multithreading(
        study::Study,
        objective::Function;
        n_trials::Int=100,
        verbose::Bool=false,
    )

Optimize the objective function.

Uses the sampler of the study which implements the task of value suggestion based on a specified distribution. For the available samplers see [Sampler](@ref).

This function works in a multi-threaded way and is used when the keyword argument `n_jobs` of `optimize` is set to a value greater than 1.

## Arguments
- `study::Study`: [Study](@ref) to which the `trial` belongs.
- `objective::Function`: Function that takes a trial and returns a score.

## Keyword Arguments
- `n_trials::Int=100`: Number of trials to run.
- `verbose::Bool=false`: If true, print information about the optimization process.

## Returns
- `Study`: The optimized study. [Study](@ref)
"""
function optimize_multithreading(
    study::Study, objective::Function; n_trials::Int=100, verbose::Bool=false
)
    PythonCall.GIL.unlock() do
        Threads.@threads for i in 1:n_trials
            if verbose
                @info "[$(Threads.threadid())] Starting trial $(i) / $(n_trials)"
            end

            trial = ask(study; multithreading=true)

            run_trial(study, trial, objective)
        end
    end

    return study
end
