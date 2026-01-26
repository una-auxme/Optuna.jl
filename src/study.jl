#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

struct Study
    study::Any
    artifact_store::Any
    storage::Any
end

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

function load_study(
    storage::BaseStorage,
    study_name::String,
    artifact_store::BaseArtifactStore;
    sampler=nothing::Union{Nothing,BaseSampler},
    pruner=nothing::Union{Nothing,BasePruner},
)
    study = optuna.load_study(;
        study_name=study_name, storage=storage.storage, sampler=sampler, pruner=pruner
    )
    return Study(study, artifact_store, storage)
end

function delete_study(study_name::String, storage::BaseStorage)
    return optuna.delete_study(; study_name=study_name, storage=storage.storage)
end

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
    ask(study)

Wrapper for the Optuna `ask` function [ToDo: link URL].
This function is safe for multithreading.

# Arguments 
- `study::Study` the study to ask.
"""
function ask(study::Study; multithreading = Threads.threadid() != 1)
    multithreading = Threads.threadid() != 1

    if multithreading
        thread_safe() do 
            return Trial{true}(study.study.ask())
        end
    else
        return Trial{false}(study.study.ask())
    end
end

"""
    tell(study, trial, score; kwargs...)

Wrapper for the Optuna `tell` function [ToDo: link URL].
This function is safe for multithreading.

# Arguments 
- `study::Study` the study to ask.
- ToDo
"""
function tell(
    study::Study, trial::Trial, score::Union{Nothing,T,Vector{T}}=nothing; prune::Bool=false, multithreading = Threads.threadid() != 1
) where {T<:AbstractFloat}
    if isnothing(score) && !prune
        throw(
            ArgumentError(
                "th the score is nothing and prune is false. Either score must not be nothing or prune must be set to true.",
            ),
        )
    end

    if multithreading
        thread_safe() do 
            if prune
                study.study.tell(trial.trial; state=optuna.trial.TrialState.PRUNED)
            else
                study.study.tell(trial.trial, score)
            end
        end
    else
        if prune
            study.study.tell(trial.trial; state=optuna.trial.TrialState.PRUNED)
        else
            study.study.tell(trial.trial, score)
        end
    end

end

function best_trial(study::Study)
    return study.study.best_trial
end

function best_params(study::Study)
    return study.study.best_params
end

function best_value(study::Study)
    return study.study.best_value
end

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

function get_all_artifact_meta(study::Study)
    return stack([get_all_artifact_meta(study, trial) for trial in study.study.trials])[
        1, :,
    ]
end

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

function download_artifact(study::Study, artifact_id::String, file_path::String)
    return optuna.artifacts.download_artifact(;
        artifact_store=study.artifact_store.artifact_store,
        artifact_id=artifact_id,
        file_path=abspath(file_path) * "$artifact_id.jld2",
    )
end
