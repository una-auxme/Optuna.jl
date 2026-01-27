#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Optuna
using Test

function setup_test_study(;
    database_path=joinpath(@__DIR__, "tmp", "storage"),
    database_name="example_db",
    study_name="example-study",
    artifact_path=joinpath(@__DIR__, "tmp", "artifacts"),
    sampler=RandomSampler(),
    pruner=MedianPruner(),
    direction="minimize",
)
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
    return study
end

include("utils.jl")

@testset "Optuna.jl" begin
    include("pruners.jl")
    include("samplers.jl")
    include("storage.jl")
    include("artifacts.jl")
    include("trial.jl")
    include("study.jl")
    @testset "optimize" begin 
        include("optimize.jl")
    end
    include("single_step.jl")
end
