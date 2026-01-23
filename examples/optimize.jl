#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Optuna

# central database storage for all studies
database_url = "example/storage"
database_name = "example_db"

# name and artifact path for the study
study_name = "example-study"
artifact_path = "example/artifacts"

# parameter search space
x_i = [0, 100]
y_i = [-10.0f0, 10.0f0]
z_i = [true, false]
param = 5.0

# used sampler and pruner
sampler = RandomSampler()
pruner = MedianPruner()

###

# Step 1: Create/Load database storage for studies
storage = RDBStorage(database_url, database_name)

# Step 2: Create artifact store for the study
artifact_store = FileSystemArtifactStore(artifact_path)

# Step 3: Create a new study (or load an existing one)
study = Study(
    study_name,
    artifact_store,
    storage;
    sampler=sampler,
    pruner=pruner,
    direction="minimize",
    load_if_exists=true,
)

# Step 4: Define objective function
function objective(trial::Trial; x, y, z)
    result = 0.0
    for step in 1:10
        sleep(10)
        result = z ? x * (y - param) : x * (y + param)
        report(trial, result, step)
        if should_prune(trial)
            return nothing
        end
    end

    upload_artifact(study, trial, Dict("x" => x, "y" => y, "z" => z, "param" => param))
    return result
end

# Step 5: Optimize the study
optimize(study, objective, (x=x_i, y=y_i, z=z_i); n_trials=10)

# Step 6: Retrieve best trial information
println("Best trial: ", best_trial(study))
println("Best params: ", best_params(study))
println("Best value: ", best_value(study))
