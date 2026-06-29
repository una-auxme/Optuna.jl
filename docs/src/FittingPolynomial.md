# Polynomial fitting

This example shows the pattern used for machine-learning and simulation workloads: wrap the training loop in an Optuna objective, suggest the model and optimizer hyperparameters at the beginning of each trial, report the validation loss during training, and store the best trial data as an artifact.

The example follows the spirit of the Lux.jl polynomial fitting tutorial. It focuses on the Optuna.jl workflow; install the machine-learning dependencies in the project where you run the example.

```julia
using Optuna
using Random
using Statistics

using Lux
using Optimisers
using Zygote
```

## Data

The target is a noisy quadratic function.

```julia
function generate_data(rng::AbstractRNG; n=128)
    x = reshape(collect(range(-2.0f0, 2.0f0; length=n)), 1, n)
    y = x .^ 2 .- 2.0f0 .* x
    y .+= 0.1f0 .* randn(rng, Float32, size(y))
    return x, y
end

rng = MersenneTwister(12345)
x, y = generate_data(rng)
```

## Model builder

The trial will choose the number of hidden layers, the hidden size, the activation function, and the learning rate. Keeping model construction in a helper makes the objective easier to read.

```julia
function build_model(num_layers, num_hidden, activation)
    layers = Any[Dense(1 => num_hidden, activation)]

    for _ in 2:num_layers
        push!(layers, Dense(num_hidden => num_hidden, activation))
    end

    push!(layers, Dense(num_hidden => 1))
    return Chain(layers...)
end
```

## Study configuration

Use persistent storage for longer experiments so that finished trials are available after Julia exits. Artifacts are written to a local directory.

```julia
storage_url = create_sqlite_url("storage", "polynomial_fitting")
storage = RDBStorage(storage_url)
artifact_store = FileSystemArtifactStore("artifacts")

study = Study(
    "polynomial-fitting",
    artifact_store,
    storage;
    sampler=TPESampler(seed=123),
    pruner=MedianPruner(n_startup_trials=5, n_warmup_steps=10),
    direction="minimize",
    load_if_exists=true,
)
```

## Objective

Each trial builds a fresh model and optimizer. The training loop reports loss after every epoch, which gives the pruner enough information to stop unpromising configurations early.

```julia
function objective(trial::Trial)
    num_layers = suggest_int(trial, "num_layers", 1, 3)
    num_hidden = suggest_categorical(trial, "num_hidden", [4, 8, 16, 32])
    activation = suggest_categorical(trial, "activation", [relu, tanh, sigmoid])
    learning_rate = suggest_float(trial, "learning_rate", 1e-4, 1e-1; log=true)

    model = build_model(num_layers, num_hidden, activation)

    rng_model = MersenneTwister(2024)
    ps, st = Lux.setup(rng_model, model)
    opt_state = Optimisers.setup(Adam(learning_rate), ps)

    loss = Inf

    for epoch in 1:250
        loss, back = Zygote.pullback(ps) do current_ps
            y_pred, _ = model(x, current_ps, st)
            mean(abs2, y_pred .- y)
        end

        gs = first(back(one(loss)))
        opt_state, ps = Optimisers.update(opt_state, ps, gs)

        report(trial, Float64(loss), epoch)
        if should_prune(trial)
            return nothing
        end
    end

    artifact_id = upload_artifact(
        study,
        trial,
        Dict(
            "num_layers" => num_layers,
            "num_hidden" => num_hidden,
            "activation" => string(activation),
            "learning_rate" => learning_rate,
            "parameters" => ps,
            "state" => st,
            "final_loss" => Float64(loss),
        ),
    )
    set_user_attr(trial, "artifact_id", artifact_id)

    return Float64(loss)
end
```

## Run and inspect

```julia
optimize(study, objective; n_trials=50, verbose=true)

println("Best parameters: ", best_params(study))
println("Best value: ", best_value(study))
```

The important design choice is that the objective owns a full training run. Optuna.jl does not need to know about Lux internals; it only needs a final score, optional intermediate reports, and optional artifacts.

## Reuse the best result

The best trial stores its artifact id in the Optuna user attributes. You can use it to download the saved model data.

```julia
using JLD2
using PythonCall

trial = best_trial(study)
user_attrs = pyconvert(Dict{String,Any}, trial.trial.user_attrs)
artifact_id = user_attrs["artifact_id"]
artifact_file = "best_model_$(artifact_id).jld2"

download_artifact(study, artifact_id, artifact_file)
best_data = JLD2.load(artifact_file)
```

The artifact contains the trained parameters, model state, and hyperparameters that were saved in the objective.
