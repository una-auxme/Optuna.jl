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
y_i = [-10.0, 10.0]
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
# with internal suggest functions
function objective(trial::Trial)
    x = suggest_int(trial, "x", x_i[1], x_i[2])
    y = suggest_float(trial, "y", y_i[1], y_i[2])
    z = suggest_categorical(trial, "z", z_i)

    result = 0.0
    for step in 1:10
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
# or with parameters as kwargs
function objective(trial::Trial; x, y, z)
    result = 0.0
    for step in 1:10
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
# or with parameters as a NamedTuple
function objective(trial::Trial, params::NamedTuple)
    result = 0.0
    for step in 1:10
        result = params.z ? params.x * (params.y - param) : params.x * (params.y + param)
        # Report the intermediate value to the trial
        report(trial, result, step)
        # Check if the trial should be pruned
        if should_prune(trial)
            return nothing
        end
    end
    # Upload artifacts related to this trial
    upload_artifact(
        study,
        trial,
        Dict("x" => params.x, "y" => params.y, "z" => params.z, "param" => param),
    )
    return result
end

# Step 5: Optimize the objective function of the study
# with parameter suggestions inside the objective function
optimize(study, objective; n_trials=10, n_jobs=1, verbose=true)
# or with a set of parameters suggested by the sampler
optimize(study, objective, (x=x_i, y=y_i, z=z_i); n_trials=10, n_jobs=1, verbose=true)

# Step 6: Retrieve best trial information
println("Best trial: ", best_trial(study))
println("Best params: ", best_params(study))
println("Best value: ", best_value(study))
