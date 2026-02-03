#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    Study(
        study_name::String,
        artifact_store::BaseArtifactStore,
        storage::BaseStorage;
        sampler=nothing::Union{Nothing,BaseSampler},
        pruner=nothing::Union{Nothing,BasePruner},
        direction::String="minimize",
        load_if_exists::Bool=true,
    )

Create a new study or load an existing one with the given name, artifact store, storage, optimization direction, sampler and pruner.

## Arguments
- `study_name::String`: Name of the study.
- `artifact_store::BaseArtifactStore`: Artifact store of the study. (see [Artifacts](@ref))
- `storage::BaseStorage`: Storage of the study. (see [Storage](@ref))

## Keyword Arguments
- `sampler::Union{Nothing,BaseSampler}=nothing`: Sampler to use for the study. (see [Sampler](@ref))
- `pruner::Union{Nothing,BasePruner}=nothing`: Pruner to use for the study. (see [Pruner](@ref))
- `direction::String="minimize"`: Direction of optimization, either "minimize" or "maximize".
- `load_if_exists::Bool=true`: If true, load the study if it already exists.

## Returns
- `Study`: The created or loaded study. (see [Study](@ref))
"""
function Study(
    study_name::String,
    artifact_store::BaseArtifactStore,
    storage::BaseStorage;
    sampler=nothing::Union{Nothing,BaseSampler},
    pruner=nothing::Union{Nothing,BasePruner},
    direction::String="minimize",
    load_if_exists::Bool=true,
)
    if direction != "minimize" && direction != "maximize"
        error("Direction of optimization must be either 'minimize' or 'maximize'")
    end

    study = optuna.create_study(;
        storage=storage.storage,
        study_name=study_name,
        sampler=isnothing(sampler) ? PythonCall.pybuiltins.None : sampler.sampler,
        pruner=isnothing(pruner) ? PythonCall.pybuiltins.None : pruner.pruner,
        direction=direction,
        load_if_exists=load_if_exists,
    )

    return Study(study, artifact_store, storage)
end

"""
    load_study(
        storage::BaseStorage,
        study_name::String,
        artifact_store::BaseArtifactStore;
        sampler=nothing::Union{Nothing,BaseSampler},
        pruner=nothing::Union{Nothing,BasePruner},
    )

Load an existing study with the given name, artifact store, storage, sampler and pruner.

## Arguments
- `study_name::String`: Name of the study.
- `artifact_store::BaseArtifactStore`: Artifact store for the study. (see [Artifacts](@ref))
- `storage::BaseStorage`: Storage of the study. (see [Storage](@ref))

## Keyword Arguments
- `sampler::Union{Nothing,BaseSampler}=nothing`: Sampler to use for the study. (see [Sampler](@ref))
- `pruner::Union{Nothing,BasePruner}=nothing`: Pruner to use for the study. (see [Pruner](@ref))
## Returns
- `Study`: The loaded study. (see [Study](@ref))
"""
function load_study(
    study_name::String,
    storage::BaseStorage,
    artifact_store::BaseArtifactStore;
    sampler=nothing::Union{Nothing,BaseSampler},
    pruner=nothing::Union{Nothing,BasePruner},
)
    study = optuna.load_study(;
        study_name=study_name, storage=storage.storage, sampler=sampler, pruner=pruner
    )
    return Study(study, artifact_store, storage)
end

"""
    delete_study(
        study_name::String,
        storage::BaseStorage,
    )

Delete a study with the given name and storage backend.

## Arguments
- `study_name::String`: Name of the study.
- `storage::BaseStorage`: Storage of the study. (see [Storage](@ref))
"""
function delete_study(study_name::String, storage::BaseStorage)
    return optuna.delete_study(; study_name=study_name, storage=storage.storage)
end

"""
    copy_study(
        from_study_name::String,
        from_storage::BaseStorage,
        to_storage::BaseStorage,
        to_study_name::String="",
    )
Copy a study from one storage backend to another.

## Arguments
- `from_study_name::String`: Name of the study to copy.
- `from_storage::BaseStorage`: Storage backend to copy the study from. (see [Storage](@ref))
- `to_storage::BaseStorage`: Storage backend to copy the study to. (see [Storage](@ref))
- `to_study_name::String=""`: Name of the new study. If empty, the original study name is used.
"""
function copy_study(
    from_study_name::String,
    from_storage::BaseStorage,
    to_storage::BaseStorage,
    to_study_name::String="",
)
    return optuna.copy_study(;
        from_study_name=from_study_name,
        from_storage=from_storage.storage,
        to_storage=to_storage.storage,
        to_study_name=isempty(to_study_name) ? PythonCall.pybuiltins.None : to_study_name,
    )
end

"""
    ask(study::Study)

Wrapper for the Optuna `ask` function [ToDo: link URL].
This function is safe for multithreading.

## Arguments
- `study::Study`: The study to ask the trial from. (see [Study](@ref))

## Keywords
- `multithreading::Bool` if multithreading is used, default is automatically detected (true if more than one thread is available)

## Returns
- `Trial`: The new trial. (see [Trial](@ref))
"""
function ask(study::Study; multithreading::Bool=Threads.nthreads() > 1)
    if multithreading
        thread_safe() do
            return Trial{true}(study.study.ask())
        end
    else
        return Trial{false}(study.study.ask())
    end
end

"""
    tell(study::Study, trial::Trial, score::Union{Nothing,T,Vector{T}}=nothing; prune::Bool=false
) where {T<:AbstractFloat}

Tell the study about the result of a trial. This is the proper way to complete a trial created with the [ask](@ref) function.

## Arguments
- `study::Study`: The study to report the trial to. (see [Study](@ref))
- `trial::Trial`: The trial which was completed. (see [Trial](@ref))
- `score::Union{Nothing,T,Vector{T}}=nothing`: The score of the trial. If `nothing`, the trial is pruned.
- `prune::Bool=false`: If true, the trial is pruned.
"""
function tell(
    study::Study,
    trial::Trial{false},
    score::Union{Nothing,T,Vector{T}}=nothing;
    prune::Bool=false,
) where {T<:AbstractFloat}
    if isnothing(score) && !prune
        throw(
            ArgumentError(
                "The score is nothing and prune is false. Either score must not be nothing or prune must be set to true.",
            ),
        )
    end

    if prune
        study.study.tell(trial.trial; state=optuna.trial.TrialState.PRUNED)
    else
        study.study.tell(trial.trial, score)
    end
end
function tell(
    study::Study,
    trial::Trial{true},
    score::Union{Nothing,T,Vector{T}}=nothing;
    prune::Bool=false,
    multithreading=Threads.threadid() != 1,
) where {T<:AbstractFloat}
    if isnothing(score) && !prune
        throw(
            ArgumentError(
                "The score is nothing and prune is false. Either score must not be nothing or prune must be set to true.",
            ),
        )
    end

    thread_safe() do
        if prune
            study.study.tell(trial.trial; state=optuna.trial.TrialState.PRUNED)
        else
            study.study.tell(trial.trial, score)
        end
    end
end

"""
    best_trial(study::Study)

Get the best trial of the study.

## Arguments
- `study::Study`: The study to get the best trial from. (see [Study](@ref))

## Returns
- `Trial`: The best trial. (see [Trial](@ref))
"""
function best_trial(study::Study)
    return Trial{false}(study.study.best_trial)
end

"""
    best_params(study::Study)

Get the best parameters of the study.

## Arguments
- `study::Study`: The study to get the best parameters from. (see [Study](@ref))

## Returns
- `Dict{String,Any}`: The best parameters.
"""
function best_params(study::Study)
    return pyconvert(Dict{String,Any}, study.study.best_params)
end

"""
    best_value(study::Study)

Get the best objective value of the study.

## Arguments
- `study::Study`: The study to get the best objective value from. (see [Study](@ref))

## Returns
- `Float64`: The best objective value.
"""
function best_value(study::Study)
    return pyconvert(Float64, study.study.best_value)
end
