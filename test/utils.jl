#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

function create_test_study(; name="test_study", kwargs...)
    test_dir = mktempdir()
    storage = RDBStorage(create_sqlite_url(test_dir, name))
    artifacts = FileSystemArtifactStore(joinpath(test_dir, "artifacts"))
    study = Study(name, artifacts, storage; kwargs...)
    return study, test_dir, storage, artifacts
end

function create_test_study(pruner::Optuna.BasePruner; name="test_study")
    test_dir = mktempdir()
    storage = RDBStorage(create_sqlite_url(test_dir, name))
    artifacts = FileSystemArtifactStore(joinpath(test_dir, "artifacts"))
    study = Study(name, artifacts, storage; pruner=pruner)
    return study, test_dir
end

function create_test_study(sampler::Optuna.BaseSampler; name="test_study")
    test_dir = mktempdir()
    storage = RDBStorage(create_sqlite_url(test_dir, name))
    artifacts = FileSystemArtifactStore(joinpath(test_dir, "artifacts"))
    study = Study(name, artifacts, storage; sampler=sampler)
    return study, test_dir
end
