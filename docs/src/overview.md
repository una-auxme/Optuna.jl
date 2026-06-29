# Overview

Optuna.jl mirrors the main Optuna concepts in Julia. This page explains how the pieces fit together before the tutorials use them in code.

## Studies and trials

A `Study` is one optimization run. It owns the trial history, optimization direction, sampler, pruner, storage backend, and artifact store.

A `Trial` is one evaluation of your objective function. During a trial you usually:

1. Suggest hyperparameters with `suggest_int`, `suggest_float`, or `suggest_categorical`.
2. Run the workload with those values.
3. Optionally call `report` with intermediate values.
4. Optionally stop early when `should_prune` returns `true`.
5. Return the final score.

The score is minimized or maximized according to the `direction` configured on the study.

## Search spaces

The most flexible way to define a search space is inside the objective:

```julia
function objective(trial::Trial)
    width = suggest_int(trial, "width", 16, 128; step=16)
    learning_rate = suggest_float(trial, "learning_rate", 1e-5, 1e-2; log=true)
    activation = suggest_categorical(trial, "activation", ["relu", "tanh"])

    return train_and_validate(width, learning_rate, activation)
end
```

This works well when later parameters depend on earlier ones. For simple fixed search spaces, `optimize` can receive a `NamedTuple` and pass the sampled values into the objective.

## Samplers

Samplers choose the next parameter values. Useful starting points are:

- `RandomSampler` for baseline random search.
- `TPESampler` for a strong general-purpose Bayesian optimization default.
- `GridSampler` or `BruteForceSampler` when the search space is small and discrete.
- `NSGAIISampler` and `NSGAIIISampler` for multi-objective optimization.

## Pruners

Pruners stop weak trials before they spend the full compute budget. To use a pruner, report intermediate values from the objective:

```julia
for epoch in 1:epochs
    validation_loss = train_one_epoch()
    report(trial, validation_loss, epoch)

    if should_prune(trial)
        return nothing
    end
end
```

Returning `nothing` tells Optuna.jl that the trial was pruned.

## Keeping trial history

Storage keeps the study and trial metadata.

- `InMemoryStorage` is convenient for quick experiments.
- `RDBStorage` stores studies in a relational database such as SQLite or MySQL.
- `JournalStorage` uses Optuna's journal storage backends.

SQLite is the easiest persistent option for local work:

```julia
storage_url = create_sqlite_url("storage", "experiment")
storage = RDBStorage(storage_url)
```

## Saving artifacts

Artifacts are files or Julia data associated with trials. Optuna.jl saves dictionaries as `.jld2` files through `upload_artifact`.

```julia
upload_artifact(
    study,
    trial,
    Dict("model_parameters" => ps, "validation_loss" => loss),
)
```

Use artifacts for model weights, generated plots, simulation outputs, or metadata that is too large or too structured for a scalar objective value.

## Parallel optimization

`optimize` can run trials on multiple Julia threads with `n_jobs > 1`.

```julia
optimize(study, objective; n_trials=100, n_jobs=4)
```

Start Julia with enough threads and exactly one interactive thread, for example:

```bash
julia -t 4,1
```

For distributed or repeated optimization runs, use persistent storage so that workers share the same trial history.
