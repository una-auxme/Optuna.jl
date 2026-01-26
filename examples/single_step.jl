#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Optuna

# central database storage for all studies
database_url = "examples/storage"
database_name = "example_db"

# name and artifact path for the study
study_name = "example-study"
artifact_path = "examples/artifacts"

# parameter search space for int(x_i), float(y_i), categorical(z_i) data
x_i = [0, 100]
y_i = [-10.0f0, 10.0f0]
z_i = [true, false]
param = 5.0

# used sampler and pruner
sampler = RandomSampler()
pruner = MedianPruner()

###

# Step 1: Create/Load database storage for studies
storage_url = create_sqlite_url(database_url, database_name)
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
    direction="minimize",
    load_if_exists=true,
)

# Step 4: Define objective function
function objective(trial::Trial; x, y, z)
    result = 0.0
    for step in 1:10
        # evaluate the objective function with the suggested parameters
        result = z ? x * (y - param) : x * (y + param)
        # Report the intermediate value to the trial
        report(trial, result, step)
        # Check if the trial should be pruned
        if should_prune(trial)
            return nothing
        end
    end
    # Upload artifacts related to this trial
    upload_artifact(study, trial, Dict("x" => x, "y" => y, "z" => z, "param" => param))
    return result
end

# Step 5: Optimize a single trial
# ask the study for a new trial
trial = ask(study)

# get a set of parameters for the trial suggested by the sampler
x = suggest_int(trial, "x", x_i[1], x_i[2])
y = suggest_float(trial, "y", y_i[1], y_i[2])
z = suggest_categorical(trial, "z", z_i)

score = objective(trial; x, y, z)

# tell the study the result of the trial. If the score was nothing, the trial should be pruned by passing prune=true
if isnothing(score)
    tell(study, trial; prune=true)
else
    tell(study, trial, score)
end

# Step 6: Retrieve best trial information
println("Best trial: ", best_trial(study))
println("Best params: ", best_params(study))
println("Best value: ", best_value(study))
