#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

abstract type BasePruner end

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
