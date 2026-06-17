#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    Study(
        study_name::String,
        artifact_store::BaseArtifactStore,
        storage::BaseStorage;
        sampler::Union{Nothing,BaseSampler}=nothing,
        pruner::Union{Nothing,BasePruner}=nothing,
        direction::String="minimize",
        directions::Union{Nothing,Vector{String}}=nothing,
        load_if_exists::Bool=true,
    )

Create a new study or load an existing one with the given name, artifact store, storage, optimization direction, sampler and pruner.
For further information see the [create_study](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.study.create_study.html) in the Optuna python documentation.

## Arguments
- `study_name::String`: Name of the study.
- `artifact_store::BaseArtifactStore`: Artifact store of the study. (see [Artifacts](@ref))
- `storage::BaseStorage`: Storage of the study. (see [Storage](@ref))

## Keyword Arguments
- `sampler::Union{Nothing,BaseSampler}=nothing`: Sampler to use for the study. (see [Sampler](@ref))
- `pruner::Union{Nothing,BasePruner}=nothing`: Pruner to use for the study. (see [Pruner](@ref))
- `direction::String="minimize"`: Direction of optimization for single-objective studies, either "minimize" or "maximize". Ignored when `directions` is provided.
- `directions::Union{Nothing,Vector{String}}=nothing`: Directions of optimization for multi-objective studies. Each element must be "minimize" or "maximize". When provided, `direction` is ignored and a multi-objective study is created.
- `load_if_exists::Bool=true`: If true, load the study if it already exists.

## Returns
- `Study`: The created or loaded study. (see [Study](@ref))
"""
function Study(
    study_name::String,
    artifact_store::BaseArtifactStore,
    storage::BaseStorage;
    sampler::Union{Nothing,BaseSampler}=nothing,
    pruner::Union{Nothing,BasePruner}=nothing,
    direction::String="minimize",
    directions::Union{Nothing,Vector{String}}=nothing,
    load_if_exists::Bool=true,
)
    py_sampler = isnothing(sampler) ? nothing : sampler.sampler
    py_pruner = isnothing(pruner) ? nothing : pruner.pruner

    if !isnothing(directions)
        for d in directions
            d ∈ ("minimize", "maximize") || error(
                "Each element of directions must be 'minimize' or 'maximize', got '$d'"
            )
        end
        study = optuna.create_study(;
            storage=storage.storage,
            study_name=study_name,
            sampler=py_sampler,
            pruner=py_pruner,
            directions=directions,
            load_if_exists=load_if_exists,
        )
    else
        direction ∈ ("minimize", "maximize") ||
            error("Direction of optimization must be either 'minimize' or 'maximize'")
        study = optuna.create_study(;
            storage=storage.storage,
            study_name=study_name,
            sampler=py_sampler,
            pruner=py_pruner,
            direction=direction,
            load_if_exists=load_if_exists,
        )
    end

    return Study(study, artifact_store, storage)
end

"""
    load_study(
        study_name::String,
        storage::BaseStorage,
        artifact_store::BaseArtifactStore;
        sampler::Union{Nothing,BaseSampler}=nothing,
        pruner::Union{Nothing,BasePruner}=nothing,
    )

Load an existing study with the given name, artifact store, storage, sampler and pruner.
For further information see the [load_study](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.study.load_study.html) in the Optuna python documentation.

## Arguments
- `study_name::String`: Name of the study.
- `storage::BaseStorage`: Storage of the study. (see [Storage](@ref))
- `artifact_store::BaseArtifactStore`: Artifact store for the study. (see [Artifacts](@ref))

## Keyword Arguments
- `sampler::Union{Nothing,BaseSampler}=nothing`: Sampler to use for the study. (see [Sampler](@ref))
- `pruner::Union{Nothing,BasePruner}=nothing`: Pruner to use for the study. (see [Pruner](@ref))
## Returns
- `Study`: The loaded study. (see [Study](@ref))
"""
function load_study(
    study_name::String,
    storage::BaseStorage,
    artifact_store::BaseArtifactStore;
    sampler::Union{Nothing,BaseSampler}=nothing,
    pruner::Union{Nothing,BasePruner}=nothing,
)
    study = optuna.load_study(;
        study_name=study_name,
        storage=storage.storage,
        sampler=isnothing(sampler) ? nothing : sampler.sampler,
        pruner=isnothing(pruner) ? nothing : pruner.pruner,
    )
    return Study(study, artifact_store, storage)
end

"""
    delete_study(
        study_name::String,
        storage::BaseStorage,
    )

Delete a study with the given name and storage backend.
For further information see the [delete_study](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.study.delete_study.html) in the Optuna python documentation.

## Arguments
- `study_name::String`: Name of the study.
- `storage::BaseStorage`: Storage of the study. (see [Storage](@ref))
"""
function delete_study(study_name::String, storage::BaseStorage)
    return optuna.delete_study(; study_name=study_name, storage=storage.storage)
end

"""
    copy_study(
        from_study_name::String,
        from_storage::BaseStorage,
        to_storage::BaseStorage,
        to_study_name::String="",
    )
Copy a study from one storage backend to another.
For further information see the [copy_study](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.study.copy_study.html) in the Optuna python documentation.

## Arguments
- `from_study_name::String`: Name of the study to copy.
- `from_storage::BaseStorage`: Storage backend to copy the study from. (see [Storage](@ref))
- `to_storage::BaseStorage`: Storage backend to copy the study to. (see [Storage](@ref))
- `to_study_name::String=""`: Name of the new study. If empty, the original study name is used.
"""
function copy_study(
    from_study_name::String,
    from_storage::BaseStorage,
    to_storage::BaseStorage,
    to_study_name::String="",
)
    return optuna.copy_study(;
        from_study_name=from_study_name,
        from_storage=from_storage.storage,
        to_storage=to_storage.storage,
        to_study_name=isempty(to_study_name) ? nothing : to_study_name,
    )
end

"""
    ask(
        study::Study;
        multithreading::Bool=Threads.nthreads() > 1
    )

Wrapper for the Optuna `ask` function. For further information see the [ask](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.study.Study.html#optuna.study.Study.ask) in the Optuna python documentation.

This function is safe for multithreading.

## Arguments
- `study::Study`: The study to ask the trial from. (see [Study](@ref))

## Keywords
- `multithreading::Bool=Threads.nthreads() > 1` if multithreading is used, default is automatically detected (`true` if more than one thread is available)

## Returns
- `Trial`: The new trial. (see [Trial](@ref))
"""
function ask(study::Study; multithreading::Bool=Threads.nthreads() > 1)
    if multithreading
        thread_safe() do
            return Trial{true}(study.study.ask())
        end
    else
        return Trial{false}(study.study.ask())
    end
end

function _validate_objectives(study::Study, objectives)
    isnothing(objectives) && return nothing
    n_dirs = pyconvert(Int, study.study.directions.__len__())
    if objectives isa Vector
        length(objectives) == n_dirs || throw(
            ArgumentError(
                "The number of objectives ($(length(objectives))) does not match the number of directions provided ($n_dirs).",
            ),
        )
    else
        n_dirs == 1 || throw(
            ArgumentError(
                "A scalar objective was provided but the study has multiple directions ($n_dirs).",
            ),
        )
    end
end

"""
    tell(
        study::Study,
        trial::Trial{false},
        score::Union{Nothing,T,Vector{T}}=nothing;
        prune::Bool=false,
) where {T<:AbstractFloat}

Tell the study about the result of a trial. This is the proper way to complete a trial created with the [ask](@ref) function.
For further information see the [tell](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.study.Study.html#optuna.study.Study.tell) in the Optuna python documentation.

## Arguments
- `study::Study`: The study to report the trial to. (see [Study](@ref))
- `trial::Trial`: The trial which was completed. (see [Trial](@ref))
- `score::Union{Nothing,T,Vector{T}}=nothing`: The score of the trial. If `nothing`, the trial is pruned.
- `prune::Bool=false`: If true, the trial is pruned.
"""
function tell(
    study::Study,
    trial::Trial{false},
    score::Union{Nothing,T,Vector{T}}=nothing;
    prune::Bool=false,
) where {T<:AbstractFloat}
    if isnothing(score) && !prune
        throw(
            ArgumentError(
                "The score is nothing and prune is false. Either score must not be nothing or prune must be set to true.",
            ),
        )
    end

    _validate_objectives(study, score)

    if prune
        study.study.tell(trial.trial; state=optuna.trial.TrialState.PRUNED)
    else
        study.study.tell(trial.trial, score)
    end
end
function tell(
    study::Study,
    trial::Trial{true},
    score::Union{Nothing,T,Vector{T}}=nothing;
    prune::Bool=false,
    multithreading=Threads.threadid() != 1,
) where {T<:AbstractFloat}
    if isnothing(score) && !prune
        throw(
            ArgumentError(
                "The score is nothing and prune is false. Either score must not be nothing or prune must be set to true.",
            ),
        )
    end

    thread_safe() do
        _validate_objectives(study, score)
        if prune
            study.study.tell(trial.trial; state=optuna.trial.TrialState.PRUNED)
        else
            study.study.tell(trial.trial, score)
        end
    end
end

"""
    best_trial(
        study::Study
    )

Get the best trial of the study. Only valid for single-objective studies.
For further information see the [best_trial](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.study.Study.html#optuna.study.Study.best_trial) in the Optuna python documentation.

## Arguments
- `study::Study`: The study to get the best trial from. (see [Study](@ref))

## Returns
- `Trial`: The best trial. (see [Trial](@ref))
"""
function best_trial(study::Study)
    pyconvert(Int, study.study.directions.__len__()) > 1 && error(
        "best_trial() is not defined for multi-objective studies. " *
        "Use best_trials() to get the Pareto front trials.",
    )
    return Trial{false}(study.study.best_trial)
end

"""
    best_params(
        study::Study
    )

Get the best parameters of the study. Only valid for single-objective studies.
For further information see the [best_params](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.study.Study.html#optuna.study.Study.best_params) in the Optuna python documentation.

## Arguments
- `study::Study`: The study to get the best parameters from. (see [Study](@ref))

## Returns
- `Dict{String,Any}`: The best parameters.
"""
function best_params(study::Study)
    pyconvert(Int, study.study.directions.__len__()) > 1 && error(
        "best_params() is not defined for multi-objective studies. " *
        "Use best_params_all() to get the parameters for all Pareto front trials.",
    )
    return pyconvert(Dict{String,Any}, study.study.best_params)
end

"""
    best_params_all(study::Study) -> Vector{Dict{String,Any}}

Return the parameter dictionaries for every Pareto-optimal trial.
For single-objective studies this wraps the single best trial's parameters in a vector.

## Arguments
- `study::Study`: The study to query. (see [Study](@ref))

## Returns
- `Vector{Dict{String,Any}}`: One dictionary per Pareto-optimal trial.
"""
function best_params_all(study::Study)
    return [pyconvert(Dict{String,Any}, t.params) for t in study.study.best_trials]
end

"""
    best_value(
        study::Study
    )

Get the best objective value of the study. Only valid for single-objective studies.
For further information see the [best_value](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.study.Study.html#optuna.study.Study.best_value) in the Optuna python documentation.

## Arguments
- `study::Study`: The study to get the best objective value from. (see [Study](@ref))

## Returns
- `Float64`: The best objective value.
"""
function best_value(study::Study)
    pyconvert(Int, study.study.directions.__len__()) > 1 && error(
        "best_value() is not defined for multi-objective studies. " *
        "Use best_values() to get the Pareto front objective values.",
    )
    return pyconvert(Float64, study.study.best_value)
end

"""
    directions(study::Study) -> Vector{String}

Return the optimization directions of the study, one per objective.
Single-objective studies return a one-element vector.

## Arguments
- `study::Study`: The study to query. (see [Study](@ref))

## Returns
- `Vector{String}`: Each element is "minimize" or "maximize".
"""
function directions(study::Study)
    return [lowercase(pyconvert(String, d.name)) for d in study.study.directions]
end

"""
    best_trials(study::Study) -> Vector

Return all Pareto-optimal trials (the Pareto front) of a multi-objective study.
Each element is a Python `FrozenTrial`; fields `.values`, `.params`, and `.number`
are accessible via PythonCall. For single-objective studies this wraps the single
best trial in a vector.

## Arguments
- `study::Study`: The study to query. (see [Study](@ref))
"""
function best_trials(study::Study)
    return Trial{false}.(pyconvert(Vector, study.study.best_trials))
end

"""
    best_values(study::Study) -> Vector{Vector{Float64}}

Return the objective value vectors for every Pareto-optimal trial.

## Arguments
- `study::Study`: The study to query. (see [Study](@ref))

## Returns
- `Vector{Vector{Float64}}`: One inner vector per Pareto-optimal trial.
"""
function best_values(study::Study)
    return [pyconvert(Vector{Float64}, t.values) for t in study.study.best_trials]
end
