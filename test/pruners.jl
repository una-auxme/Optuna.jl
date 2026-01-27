#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

function test_pruner(pruner::Optuna.BasePruner)
    study, test_dir = create_test_study(; pruner=pruner)

    # complete trials to establish baseline
    for value in [1.0, 2.0, 3.0]
        trial = ask(study)
        report(trial, value, 0)
        tell(study, trial, value)
    end

    # new trial with bad value
    trial = ask(study)
    report(trial, 100.0, 0)
    @test should_prune(trial) == true
    @test should_prune(trial) isa Bool

    tell(study, trial, 100.0)
    rm(test_dir; recursive=true)
    return nothing
end

@testset "pruners" begin
    @testset "MedianPruner" begin
        pruner = MedianPruner(2, 0, 1; n_min_trials=1)
        @test pruner isa MedianPruner
        test_pruner(pruner)
    end
end
