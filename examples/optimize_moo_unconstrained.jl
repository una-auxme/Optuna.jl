using Optuna

# Central database storage for all studies
database_url = "examples/storage"
database_name = "example_db"

# Name and artifact path for the study
study_name = "example-study"
artifact_path = "examples/artifacts"

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
    sampler=NSGAIISampler(population_size=50),
    directions=["minimize", "minimize"]
)

# Step 4: Define objective functions
obj1(x) = x^2
obj2(x) = (x - 2)^2

schaffer(trial::Trial) =
    let x = suggest_float(trial, "x", -10.0, 10.0)
        [obj1(x), obj2(x)]
    end

# Step 5: Optimize the objective function of the study
optimize(study, schaffer; n_trials=10, n_jobs=1, verbose=true)

# Step 6: Retrieve best trial information
println("Best trials: ", best_trials(study))
println("Best params: ", best_params_all(study))

pareto = best_values(study)
println("Pareto front: $(length(pareto)) solutions")
for v in pareto
    println("  f1=$(round(v[1], digits=4))  f2=$(round(v[2], digits=4))")
end