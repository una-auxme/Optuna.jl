# Optuna.jl

Optuna.jl provides a Julia interface to the Python package [Optuna](https://optuna.org/), a framework for hyperparameter optimization. It lets Julia code define studies, ask Optuna for trial parameters, report intermediate values for pruning, and store the result history in an Optuna-compatible backend.

Use Optuna.jl when you have an objective function that can be evaluated repeatedly with different parameters, for example model training, numerical solver configuration, preprocessing choices, or a simulation setup.

## Installation

Install Optuna.jl from the Julia package manager:

```julia
pkg> add Optuna
```

Optuna.jl uses [PythonCall.jl](https://github.com/JuliaPy/PythonCall.jl) and [CondaPkg.jl](https://github.com/JuliaPy/CondaPkg.jl) to load the Python Optuna package and optional Python dependencies. The package manages the Python side for the common workflows shown in these docs.

## A minimal study

The core workflow is:

1. Create storage for the trial history.
2. Create a `Study`.
3. Define an objective function that accepts a `Trial`.
4. Suggest parameters inside the objective.
5. Run `optimize` and inspect the best result.

```julia
using Optuna

storage = InMemoryStorage()
artifact_store = FileSystemArtifactStore("artifacts")

study = Study(
    "minimal-study",
    artifact_store,
    storage;
    sampler=TPESampler(seed=1),
    direction="minimize",
)

function objective(trial::Trial)
    x = suggest_float(trial, "x", -10.0, 10.0)
    y = suggest_int(trial, "y", -5, 5)

    return (x - 2.0)^2 + (y + 1)^2
end

optimize(study, objective; n_trials=25)

best_params(study)
best_value(study)
```

## Documentation map

Start with [Overview](@ref) for the concepts behind studies, trials, samplers, pruners, storage, and artifacts.

The [First optimization](@ref) page walks through a complete small workflow with pruning and artifacts.

The [Polynomial fitting](@ref) example shows how to wrap a training loop in an Optuna objective.

The [Reference](@ref) page explains the available Optuna.jl building blocks and links to their docstrings.

## License

Optuna.jl and this documentation page are licensed under the project MIT
license. Portions of the API documentation and interface descriptions are
adapted from Optuna, and the polynomial-fitting example is adapted from
Lux.jl. See the [License](license.md) page for the complete project and
third-party license texts.
