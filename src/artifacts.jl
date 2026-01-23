#
# Copyright (c) 2026 Julian Trommer
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using JLD2

abstract type BaseArtifactStore end

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
