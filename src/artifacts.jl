#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using JLD2

"""
    FileSystemArtifactStore(path::String)

Data structure for a file system based artifact store.

## Arguments
- `path::String`: Path to the directory where artifacts are stored.
"""
struct FileSystemArtifactStore <: BaseArtifactStore
    artifact_store::Any
    path::String

    function FileSystemArtifactStore(path::String)
        mkpath(abspath(path))

        artifact_store = optuna.artifacts.FileSystemArtifactStore(abspath(path))
        return new(artifact_store, abspath(path))
    end
end

"""
    ArtifactMeta

Data structure containing metadata for an artifact.
"""
struct ArtifactMeta
    artifact_id::String
    mimetype::String
    encoding::Union{String,Nothing}
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
