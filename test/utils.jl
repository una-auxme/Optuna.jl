#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

function create_test_study(;
    path=mktempdir(),
    database_name="test_db",
    study_name="test-study",
    sampler=RandomSampler(),
    pruner=MedianPruner(),
    direction="minimize",
)
    database_path=joinpath(path, "storage")
    artifact_path=joinpath(path, "artifacts")

    if !isdir(database_path)
        mkdir(database_path)
    end
    if !isdir(artifact_path)
        mkdir(artifact_path)
    end

    # Step 1: Create/Load database storage for studies
    storage_url = create_sqlite_url(database_path, database_name)
    storage = RDBStorage(storage_url)

    # Step 2: Create artifact store for the study
    artifact_store = FileSystemArtifactStore(artifact_path)

    # Step 3: Create a new study (or load an existing one)
    study = Study(
        study_name,
        artifact_store,
        storage;
        sampler=sampler,
        pruner=pruner,
        direction=direction,
        load_if_exists=true,
    )
    return study, path
end
