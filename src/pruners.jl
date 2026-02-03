#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    MedianPruner(n_startup_trials::Int=5,
        n_warmup_steps::Int=0,
        interval_steps::Int=1;
        n_min_trials::Int=1)

Pruner using the median stopping rule. Prune if the trial's best intermediate result is worse than median of intermediate results of previous trials at the same step.

## Arguments
- `n_startup_trials::Int=5`: Pruning is disabled until the given number of trials finish in the same study.
- `n_warmup_steps::Int=0`: Pruning is disabled until the trial exceeds the given number of step. Note that this feature assumes that `step` starts at zero.
- `interval_steps::Int=1`: Interval in number of steps between the pruning checks, offset by the warmup steps. If no value has been reported at the time of a pruning check, that particular check will be postponed until a value is reported.
- `n_min_trials::Int=1`: Minimum number of reported trial results at a step to judge whether to prune. If the number of reported intermediate values from all trials at the current step is less than `n_min_trials`, the trial will not be pruned.
"""
struct MedianPruner <: BasePruner
    pruner::Any

    function MedianPruner(
        n_startup_trials::Int=5,
        n_warmup_steps::Int=0,
        interval_steps::Int=1;
        n_min_trials::Int=1,
    )
        pruner = optuna.pruners.MedianPruner(
            n_startup_trials, n_warmup_steps, interval_steps; n_min_trials=n_min_trials
        )
        return new(pruner)
    end
end

"""
    NopPruner()

Pruner which never prunes trials.
"""
struct NopPruner <: BasePruner
    pruner::Any

    function NopPruner()
        pruner = optuna.pruners.NopPruner()
        return new(pruner)
    end
end

"""
    PatientPruner(wrapped_pruner::Union{BasePruner,Nothing},
        patience::Int;
        min_delta::Float64=0.0)

Pruner which wraps another pruner with tolerance. This pruner monitors intermediate values in a trial and prunes the trial if the improvement in the intermediate values after a patience period is less than a threshold.

## Arguments
- `wrapped_pruner::Union{BasePruner,Nothing}`: Wrapped pruner to perform pruning when PatientPruner allows a trial to be pruned. If it is `nothing`, this pruner is equivalent to early-stopping taken the intermediate values in the individual trial.
- `patience::Int`: Pruning is disabled until the objective doesn't improve for patience consecutive steps.
- `min_delta::Float64=0.0`: Tolerance value to check whether or not the objective improves. This value should be non-negative.
"""
struct PatientPruner <: BasePruner
    pruner::Any

    function PatientPruner(
        wrapped_pruner::Union{BasePruner,Nothing}, patience::Int; min_delta::Float64=0.0
    )
        py_wrapped =
            isnothing(wrapped_pruner) ? PythonCall.pybuiltins.None : wrapped_pruner.pruner
        pruner = optuna.pruners.PatientPruner(py_wrapped, patience; min_delta=min_delta)
        return new(pruner)
    end
end

"""
    PercentilePruner(percentile::Float64,
        n_startup_trials::Int=5,
        n_warmup_steps::Int=0,
        interval_steps::Int=1;
        n_min_trials::Int=1)

Pruner to keep the specified percentile of the trials. Prune if the best intermediate value is in the bottom percentile among trials at the same step.

## Arguments
- `percentile::Float64`: Percentile which must be between 0 and 100 inclusive (e.g., When given 25.0, top of 25th percentile trials are kept).
- `n_startup_trials::Int=5`: Pruning is disabled until the given number of trials finish in the same study.
- `n_warmup_steps::Int=0`: Pruning is disabled until the trial exceeds the given number of step. Note that this feature assumes that `step` starts at zero.
- `interval_steps::Int=1`: Interval in number of steps between the pruning checks, offset by the warmup steps. If no value has been reported at the time of a pruning check, that particular check will be postponed until a value is reported. Value must be at least 1.
- `n_min_trials::Int=1`: Minimum number of reported trial results at a step to judge whether to prune. If the number of reported intermediate values from all trials at the current step is less than `n_min_trials`, the trial will not be pruned.
"""
struct PercentilePruner <: BasePruner
    pruner::Any

    function PercentilePruner(
        percentile::Float64,
        n_startup_trials::Int=5,
        n_warmup_steps::Int=0,
        interval_steps::Int=1;
        n_min_trials::Int=1,
    )
        pruner = optuna.pruners.PercentilePruner(
            percentile,
            n_startup_trials,
            n_warmup_steps,
            interval_steps;
            n_min_trials=n_min_trials,
        )
        return new(pruner)
    end
end

"""
    SuccessiveHalvingPruner(;
        min_resource::Union{String,Int}="auto",
        reduction_factor::Int=4,
        min_early_stopping_rate::Int=0,
        bootstrap_count::Int=0)

Pruner using Asynchronous Successive Halving Algorithm.

## Arguments
- `min_resource::Union{String,Int}="auto"`: A parameter for specifying the minimum resource allocated to a trial (in the paper this parameter is referred to as r). This parameter defaults to "auto" where the value is determined based on a heuristic that looks at the number of required steps for the first trial to complete.
- `reduction_factor::Int=4`: A parameter for specifying reduction factor of promotable trials (in the paper this parameter is referred to as η). At the completion point of each rung, about 1/reduction_factor trials will be promoted.
- `min_early_stopping_rate::Int=0`: A parameter for specifying the minimum early-stopping rate (in the paper this parameter is referred to as s).
- `bootstrap_count::Int=0`: Minimum number of trials that need to complete a rung before any trial is considered for promotion into the next rung.
"""
struct SuccessiveHalvingPruner <: BasePruner
    pruner::Any

    function SuccessiveHalvingPruner(;
        min_resource::Union{String,Int}="auto",
        reduction_factor::Int=4,
        min_early_stopping_rate::Int=0,
        bootstrap_count::Int=0,
    )
        pruner = optuna.pruners.SuccessiveHalvingPruner(;
            min_resource=min_resource,
            reduction_factor=reduction_factor,
            min_early_stopping_rate=min_early_stopping_rate,
            bootstrap_count=bootstrap_count,
        )
        return new(pruner)
    end
end

"""
    HyperbandPruner(;
        min_resource::Int=1,
        max_resource::Union{String,Int}="auto",
        reduction_factor::Int=3,
        bootstrap_count::Int=0)

Pruner using Hyperband.

## Arguments
- `min_resource::Int=1`: A parameter for specifying the minimum resource allocated to a trial noted as r in the paper. A smaller r will give a result faster, but a larger r will give a better guarantee of successful judging between configurations.
- `max_resource::Union{String,Int}="auto"`: A parameter for specifying the maximum resource allocated to a trial. This value represents and should match the maximum iteration steps (e.g., the number of epochs for neural networks). When this argument is "auto", the maximum resource is estimated according to the completed trials.
- `reduction_factor::Int=3`: A parameter for specifying reduction factor of promotable trials noted as η in the paper.
- `bootstrap_count::Int=0`: Parameter specifying the number of trials required in a rung before any trial can be promoted. Incompatible with `max_resource="auto"`.
"""
struct HyperbandPruner <: BasePruner
    pruner::Any

    function HyperbandPruner(;
        min_resource::Int=1,
        max_resource::Union{String,Int}="auto",
        reduction_factor::Int=3,
        bootstrap_count::Int=0,
    )
        pruner = optuna.pruners.HyperbandPruner(;
            min_resource=min_resource,
            max_resource=max_resource,
            reduction_factor=reduction_factor,
            bootstrap_count=bootstrap_count,
        )
        return new(pruner)
    end
end

"""
    ThresholdPruner(;
        lower::Union{Float64,Nothing}=nothing,
        upper::Union{Float64,Nothing}=nothing,
        n_warmup_steps::Int=0,
        interval_steps::Int=1)

Pruner to detect outlying metrics of the trials. Prune if a metric exceeds upper threshold, falls behind lower threshold or reaches NaN.

## Arguments
- `lower::Union{Float64,Nothing}=nothing`: A minimum value which determines whether pruner prunes or not. If an intermediate value is smaller than lower, it prunes.
- `upper::Union{Float64,Nothing}=nothing`: A maximum value which determines whether pruner prunes or not. If an intermediate value is larger than upper, it prunes.
- `n_warmup_steps::Int=0`: Pruning is disabled if the step is less than the given number of warmup steps.
- `interval_steps::Int=1`: Interval in number of steps between the pruning checks, offset by the warmup steps. If no value has been reported at the time of a pruning check, that particular check will be postponed until a value is reported. Value must be at least 1.
"""
struct ThresholdPruner <: BasePruner
    pruner::Any

    function ThresholdPruner(;
        lower::Union{Float64,Nothing}=nothing,
        upper::Union{Float64,Nothing}=nothing,
        n_warmup_steps::Int=0,
        interval_steps::Int=1,
    )
        py_lower = isnothing(lower) ? PythonCall.pybuiltins.None : lower
        py_upper = isnothing(upper) ? PythonCall.pybuiltins.None : upper
        pruner = optuna.pruners.ThresholdPruner(;
            lower=py_lower,
            upper=py_upper,
            n_warmup_steps=n_warmup_steps,
            interval_steps=interval_steps,
        )
        return new(pruner)
    end
end

"""
    WilcoxonPruner(;
        p_threshold::Float64=0.1,
        n_startup_steps::Int=2)

WilcoxonPruner depends on Scipy, which isnt shipped with this package by default. 
Pruner based on the Wilcoxon signed-rank test. This pruner performs the Wilcoxon signed-rank test between the current trial and the current best trial, and stops whenever the pruner is sure up to a given p-value that the current trial is worse than the best one.

## Arguments
- `p_threshold::Float64=0.1`: The p-value threshold for pruning. This value should be between 0 and 1. A trial will be pruned whenever the pruner is sure up to the given p-value that the current trial is worse than the best trial. The larger this value is, the more aggressive pruning will be performed.
- `n_startup_steps::Int=2`: The number of steps before which no trials are pruned. Pruning starts only after you have n_startup_steps steps of available observations for comparison between the current trial and the best trial.
"""
struct WilcoxonPruner <: BasePruner
    pruner::Any
    function WilcoxonPruner(; p_threshold::Float64=0.1, n_startup_steps::Int=2)
        @warn "WilcoxonPruner depends on Scipy.stats, which is not included with this package by default. To use WilcoxonPruner you would have to add it to the CondaPkg.toml"
        pruner = optuna.pruners.WilcoxonPruner(;
            p_threshold=p_threshold, n_startup_steps=n_startup_steps
        )
        return new(pruner)
    end
end
