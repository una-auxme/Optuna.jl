# First optimization

This page builds a first Optuna.jl optimization from start to finish. The objective is intentionally small so that the Optuna workflow is visible: create a study, let each trial suggest parameters, report intermediate values, prune weak trials, and inspect the best result.

## Setup

Load Optuna.jl and create storage for the study.

```julia
using Optuna
```

Optuna separates two kinds of persistence:

- `storage` stores the study, trials, parameter values, and objective values.
- `artifact_store` stores files or Julia data associated with a trial.

For a first local run, in-memory study storage is enough. A file-system artifact store is still useful because it shows the same artifact workflow used in larger experiments.

```julia
storage = InMemoryStorage()
artifact_store = FileSystemArtifactStore("artifacts")
```

If you want to keep trial history across Julia sessions, use SQLite instead:

```julia
storage_url = create_sqlite_url("storage", "first_optimization")
storage = RDBStorage(storage_url)
```

## Create the study

A `Study` owns the optimization direction and the strategy objects used during optimization.

```julia
study = Study(
    "first-optimization",
    artifact_store,
    storage;
    sampler=TPESampler(seed=123),
    pruner=MedianPruner(),
    direction="minimize",
    load_if_exists=true,
)
```

The sampler chooses new parameter values. The pruner can stop trials early after you report intermediate values. For a first optimization, `TPESampler` and `MedianPruner` are good defaults.

## Define the objective

An objective function receives a `Trial`. Each trial asks for parameter values with `suggest_int`, `suggest_float`, or `suggest_categorical`.

```julia
function objective(trial::Trial)
    x = suggest_float(trial, "x", -10.0, 10.0)
    y = suggest_int(trial, "y", -5, 5)
    use_offset = suggest_categorical(trial, "use_offset", [true, false])

    offset = use_offset ? 2.0 : 0.0
    value = Inf

    for step in 1:10
        progress = step / 10
        value = (x - 2.0)^2 + (y + 1)^2 + offset / progress

        report(trial, value, step)
        if should_prune(trial)
            return nothing
        end
    end

    upload_artifact(
        study,
        trial,
        Dict(
            "x" => x,
            "y" => y,
            "use_offset" => use_offset,
            "objective_value" => value,
        ),
    )

    return value
end
```

Returning `nothing` marks the trial as pruned. Returning a number completes the trial with that objective value.

## Run the optimization

```julia
optimize(study, objective; n_trials=30, verbose=true)

println("Best parameters: ", best_params(study))
println("Best value: ", best_value(study))
```

The result should move toward `x = 2`, `y = -1`, and `use_offset = false`, because that combination minimizes the objective.

## Passing a search space separately

You can also pass a search space to `optimize`. In that mode, Optuna.jl suggests the parameters before calling the objective and passes them either as keyword arguments or as a `NamedTuple`.

```julia
search_space = (
    x=(-10.0, 10.0),
    y=(-5, 5),
    use_offset=[true, false],
)

function objective(trial::Trial; x, y, use_offset)
    offset = use_offset ? 2.0 : 0.0
    return (x - 2.0)^2 + (y + 1)^2 + offset
end

optimize(study, objective, search_space; n_trials=30)
```

Suggesting inside the objective is more flexible for conditional search spaces. Passing a search space separately is compact when every trial uses the same parameters.
