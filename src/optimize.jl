#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

const lk_ask = ReentrantLock()

function lock_ask(f)
    lock(lk_ask)
    try
        f()
    finally
        unlock(lk_ask)
    end
end

function optimize(study::Study, objective::Function, params::NamedTuple; n_trials=100::Int, n_jobs=Threads.nthreads(), verbose::Bool=false)

    #@assert n_jobs == 1 "The study does not support multithreading, please use keyword `multithreading=true` for constructing the study."
    multithreading = n_jobs > 1

    PythonCall.GIL.unlock() do
        Threads.@threads for i in 1:n_trials

            if verbose
                @info "[$(Threads.threadid())] Starting trial $(i) / $(n_trials)"
            end

            args_fn = Dict{Symbol,Any}()

            trial = ask(study; multithreading=multithreading)

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
            
            #PythonCall.GIL.lock() do 
                if isnothing(score)
                    tell(study, trial; prune=true, multithreading=multithreading)
                else
                    tell(study, trial, score; multithreading=multithreading)
                end
            #end

        end
    end

    return study
end

# function optimize(study::Study{true}, objective::Function, params::NamedTuple; n_trials=100::Int, n_jobs=1)

#     @assert n_jobs <= Threads.nthreads() "`optimize` is called with keyword `n_jobs=$(n_jobs)`, but process only provides $(Threads.nthreads()) threads."
#     @assert n_jobs < 1 || Threads.nthreads(:interactive) == 1 "`optimize` is called with keyword `n_jobs=$(n_jobs)`, therefore we require exactly one interactive thread. The number of interactive threads is `$(Threads.nthreads(:interactive))`."
#     if n_jobs > 1 && n_jobs < Threads.nthreads()
#         @warn "`optimize` is called with keyword `n_jobs=$(n_jobs)`, however, $(Threads.nthreads()) are allocated. All threads will be used for calculation."
#     end

#     PythonCall.GIL.unlock() do
#         Threads.@threads for i in 1:n_trials

#             @info "Starting $i,$(Threads.threadid()) / $(n_trials)"

#             args_fn = Dict{Symbol,Any}()

#             trial = nothing

#             lock_ask() do
#                 PythonCall.GIL.lock() do 
#                     trial = Optuna.ask(study)

#                     for k in keys(params)
#                         v = params[k]
#                         if v[1] isa Signed
#                             args_fn[k] = Optuna.suggest_int(trial, string(k), v[1], v[2])
#                         elseif v[1] isa AbstractFloat
#                             args_fn[k] = Optuna.suggest_float(trial, string(k), v[1], v[2])
#                         elseif v isa Vector
#                             args_fn[k] = Optuna.suggest_categorical(trial, string(k), v)
#                         else
#                             error(
#                                 "Unsupported parameter type for key: $k => value $(typeof(v)). Possible types are Int, AbstractFloat, and Vector.",
#                             )
#                         end
#                     end
#                 end
#             end
            
#             score = objective(trial; args_fn...)
            
#             PythonCall.GIL.lock() do 
#                 if isnothing(score)
#                     Optuna.tell(study, trial; prune=true)
#                 else
#                     Optuna.tell(study, trial, score)
#                 end
#             end

#         end
#     end

#     return study
# end