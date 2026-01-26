#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

abstract type BasePruner end

"""
    MedianPruner(n_startup_trials::Int=5,
        n_warmup_steps::Int=0,
        interval_steps::Int=1;
        n_min_trials::Int=1)

Prune a trial if its best intermediate result is below the median of intermediate results of previous completed trials at the same step.

## Arguments
- `n_startup_trials::Int=5`: Number of initial trials before pruning starts.
- `n_warmup_steps::Int=0`: Number of steps in a trial before pruning starts.
- `interval_steps::Int=1`: Interval in number of steps when the pruner checks, offset by `n_warmup_steps`.
- `n_min_trials::Int=1`: Minimum trials needed at a step to trigger pruning. If reported results are below `n_min_trials`, the trial continues regardless of performance.
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
