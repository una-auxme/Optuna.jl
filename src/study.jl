#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    Study(study, artifact_stpre, storage)

This data structure represents an Optuna study and its corresponding artifact and data storage. A study is a collection of trials that share the same optimization objective.
"""
struct Study
    study::Any
    artifact_store::Any
    storage::Any
end

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
- `trial`: The best trial. (see [Trial](@ref))
"""
function best_trial(study::Study)
    return study.study.best_trial
end

"""
    best_params(study::Study)

Get the best parameters of the study.

## Arguments
- `study::Study`: The study to get the best parameters from. (see [Study](@ref))

## Returns
- `parameters`: The best parameters.
"""
function best_params(study::Study)
    return study.study.best_params
end

"""
    best_value(study::Study)

Get the best objective value of the study.

## Arguments
- `study::Study`: The study to get the best objective value from. (see [Study](@ref))

## Returns
- `value`: The best objective value.
"""
function best_value(study::Study)
    return study.study.best_value
end

"""
    upload_artifact(study::Study, trial::Trial, data::Dict)

Upload an artifact for a given trial in the study. The artifact is a .jld2 file containing the provided data.

## Arguments
- `study::Study`: The study to upload the artifact to. (see [Study](@ref))
- `trial::Trial`: The trial to associate the artifact with. (see [Trial](@ref))
- `data::Dict`: The data to be stored as an artifact.
"""
function upload_artifact(study::Study, trial::Trial{false}, data::Dict)
    artifact_file = joinpath(study.artifact_store.path, "artifact.jld2")

    JLD2.save(artifact_file, data)
    artifact_id = optuna.artifacts.upload_artifact(;
        artifact_store=study.artifact_store.artifact_store,
        file_path=artifact_file,
        study_or_trial=trial.trial,
        storage=study.storage.storage,
    )
    trial.trial.set_user_attr("artifact_id", artifact_id)

    return rm(artifact_file)
end
function upload_artifact(study::Study, trial::Trial{true}, data::Dict)
    artifact_file = joinpath(study.artifact_store.path, "artifact.jld2")

    thread_safe() do
        JLD2.save(artifact_file, data)
        artifact_id = optuna.artifacts.upload_artifact(;
            artifact_store=study.artifact_store.artifact_store,
            file_path=artifact_file,
            study_or_trial=trial.trial,
            storage=study.storage.storage,
        )
        trial.trial.set_user_attr("artifact_id", artifact_id)

        return rm(artifact_file)
    end
end

"""
    get_all_artifact_meta(study::Study)

Get all artifact metadata for all trials in the given study.

## Arguments
- `study::Study`: The study to get the artifact metadata from. (see [Study](@ref))

## Returns
- `Vector{ArtifactMeta}`: List of artifact metadata of all artifacts in the study.
"""
function get_all_artifact_meta(study::Study)
    return stack([get_all_artifact_meta(study, trial) for trial in study.study.trials])[
        1, :,
    ]
end

"""
    get_all_artifact_meta(study::Study, trial)

Get all artifact metadata for the trial in the given study.

## Arguments
- `study::Study`: The study to get the artifact metadata from. (see [Study](@ref))
- `trial`: The trial to get the artifact metadata from. (see [Trial](@ref))

## Returns
- `Vector{ArtifactMeta}`: List of artifact metadata of the given trial.
"""
function get_all_artifact_meta(study::Study, trial)
    artifact_metas = optuna.artifacts.get_all_artifact_meta(
        trial; storage=study.storage.storage
    )
    return [
        ArtifactMeta(
            pyconvert(String, am.artifact_id),
            pyconvert(String, am.mimetype),
            if pyconvert(Bool, am.encoding != PythonCall.pybuiltins.None)
                pyconvert(String, am.encoding)
            else
                nothing
            end,
        ) for am in artifact_metas
    ]
end

"""
    download_artifact(study::Study, artifact_id::String, file_path::String)

Download an artifact from a given study identified by its artifact_id and the file_path where it should be stored.

## Arguments
- `study::Study`: The study to download the artifact from. (see [Study](@ref))
- `artifact_id::String`: The ID of the artifact to download.
- `file_path::String`: The path where the downloaded artifact should be stored.
"""
function download_artifact(study::Study, artifact_id::String, file_path::String)
    return optuna.artifacts.download_artifact(;
        artifact_store=study.artifact_store.artifact_store,
        artifact_id=artifact_id,
        file_path=abspath(file_path) * "$artifact_id.jld2",
    )
end
