# Optuna.jl

[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://una-auxme.github.io/Optuna.jl/dev)
[![Build Status](https://github.com/una-auxme/Optuna.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/una-auxme/Optuna.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/JuliaDiff/BlueStyle)
[![Coverage](https://codecov.io/gh/una-auxme/Optuna.jl/branch/main/graph/badge.svg)](https://app.codecov.io/gh/una-auxme/Optuna.jl) 

[Optuna.jl](https://github.com/una-auxme/Optuna.jl) is a software package for the Julia programming language that provides an API Interface for the open source hyperparameter optimization framework [Optuna](https://optuna.org/).

This package is based on the Python API that is provided by Preferred Networks, Inc. in their [GitHub repository](https://github.com/optuna/optuna).

> “Optuna, the Optuna logo and any related marks are trademarks of Preferred Networks, Inc.”

## How to install Optuna.jl

1. Open the Jula REPL. Type `]` to open the package manager.
2. Install Optuna
```@julia
    pkg> add Optuna
```
3. Examples for hyperparameter optimization are provided in the [examples folder](https://github.com/una-auxme/Optuna.jl/tree/main/examples). You can also refer to the [documentation](https://una-auxme.github.io/Optuna.jl/dev/overview) for further information.

## How to use Optuna.jl
The purest way to set up a hyperparameter optimization is shown in the following. For more advanced topics - like storing artifacts, multithreading, and more - see the [examples folder](https://github.com/una-auxme/Optuna.jl/tree/main/examples).
```@julia
using Optuna

# central database storage for all studies
database_url = "examples/storage"
database_name = "example_db"

# name and artifact path for the study
study_name = "example-study"
artifact_path = "examples/artifacts"

# Create/Load database storage for studies
storage_url = create_sqlite_url(database_url, database_name)
storage = RDBStorage(storage_url)

# Create artifact store for the study
artifact_store = FileSystemArtifactStore(artifact_path)

study = Study(
    study_name,
    artifact_store,
    storage;
    direction="minimize",
    load_if_exists=true,
)

function objective(trial::Trial; x, y, z)
    result = z ? x * (y - param) : x * (y + param)
    return result
end

optimize(study, objective, (x=[0, 100], y=[-10.0f0, 10.0f0], z=[true, false]); n_trials=10, n_jobs=1, verbose=true)

println("Best params: ", best_params(study))
println("Best value: ", best_value(study))
```

## How to contribute

Contributors are welcome. Before contributing, please read, understand and follow the [Contributor's Guide](https://github.com/SciML/ColPrac) on Collaborative Practices for Community Packages.