#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofman, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using JLD2

abstract type BaseArtifactStore end

struct FileSystemArtifactStore <: BaseArtifactStore
    artifact_store::Any
    path::String

    function FileSystemArtifactStore(path::String)
        mkpath(abspath(path))

        artifact_store = optuna.artifacts.FileSystemArtifactStore(abspath(path))
        return new(artifact_store, abspath(path))
    end
end

struct ArtifactMeta
    artifact_id::String
    mimetype::String
    encoding::Union{String,Nothing}
end
