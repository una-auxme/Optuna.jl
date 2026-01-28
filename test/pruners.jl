#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
Test that a pruner can be used with a study and should_prune returns a Bool.
"""
function test_pruner_basic(pruner::Optuna.BasePruner)
    study, _ = create_test_study(; pruner=pruner)
    trial = ask(study)
    report(trial, 1.0, 0)
    @test should_prune(trial) isa Bool
    tell(study, trial, 1.0)
    return nothing
end

"""
Test that a pruner prunes trials with bad values after establishing a baseline.
"""
function test_pruner_prunes(pruner::Optuna.BasePruner)
    study, _ = create_test_study(; pruner=pruner)

    # complete trials to establish baseline
    for value in [1.0, 2.0, 3.0]
        trial = ask(study)
        report(trial, value, 0)
        tell(study, trial, value)
    end

    # new trial with bad value should be pruned
    trial = ask(study)
    report(trial, 100.0, 0)
    @test should_prune(trial) == true
    tell(study, trial, 100.0)
    return nothing
end

@testset "pruners" begin
    @testset "MedianPruner" begin
        pruner = MedianPruner(2, 0, 1; n_min_trials=1)
        @test pruner isa MedianPruner
        test_pruner_basic(pruner)
        test_pruner_prunes(pruner)
    end

    @testset "NopPruner" begin
        pruner = NopPruner()
        @test pruner isa NopPruner
        test_pruner_basic(pruner)

        # NopPruner should never prune, even with bad value
        study, _ = create_test_study(; pruner=pruner)
        for value in [1.0, 2.0, 3.0]
            trial = ask(study)
            report(trial, value, 0)
            tell(study, trial, value)
        end
        trial = ask(study)
        report(trial, 100.0, 0)
        @test should_prune(trial) == false
        tell(study, trial, 100.0)
    end

    @testset "PatientPruner" begin
        pruner = PatientPruner(MedianPruner(2, 0, 1; n_min_trials=1), 1)
        @test pruner isa PatientPruner
        test_pruner_basic(pruner)

        # also test with nothing as wrapped pruner
        @test PatientPruner(nothing, 2) isa PatientPruner
    end

    @testset "PercentilePruner" begin
        pruner = PercentilePruner(25.0, 2, 0, 1; n_min_trials=1)
        @test pruner isa PercentilePruner
        test_pruner_basic(pruner)
        test_pruner_prunes(pruner)
    end

    @testset "SuccessiveHalvingPruner" begin
        pruner = SuccessiveHalvingPruner(; min_resource=1)
        @test pruner isa SuccessiveHalvingPruner
        test_pruner_basic(pruner)

        # test pruning with multiple steps (ASHA uses rungs)
        study, _ = create_test_study(; pruner=pruner)
        for i in 1:5
            trial = ask(study)
            for step in 0:3
                report(trial, Float64(i), step)
            end
            tell(study, trial, Float64(i))
        end
        trial = ask(study)
        report(trial, 100.0, 0)
        @test should_prune(trial) isa Bool
        tell(study, trial, 100.0)
    end

    @testset "HyperbandPruner" begin
        pruner = HyperbandPruner(; min_resource=1, max_resource=10)
        @test pruner isa HyperbandPruner
        test_pruner_basic(pruner)

        # test pruning with multiple steps
        study, _ = create_test_study(; pruner=pruner)
        for i in 1:5
            trial = ask(study)
            for step in 0:3
                report(trial, Float64(i), step)
            end
            tell(study, trial, Float64(i))
        end
        trial = ask(study)
        report(trial, 100.0, 0)
        @test should_prune(trial) isa Bool
        tell(study, trial, 100.0)
    end

    @testset "ThresholdPruner" begin
        pruner = ThresholdPruner(; lower=0.0, upper=10.0)
        @test pruner isa ThresholdPruner
        test_pruner_basic(pruner)

        study, _ = create_test_study(; pruner=pruner)

        # value within threshold - should not prune
        trial = ask(study)
        report(trial, 5.0, 0)
        @test should_prune(trial) == false
        tell(study, trial, 5.0)

        # value above upper threshold - should prune
        trial = ask(study)
        report(trial, 100.0, 0)
        @test should_prune(trial) == true
        tell(study, trial, 100.0)
    end

    @testset "WilcoxonPruner" begin
        pruner = WilcoxonPruner()
        @test pruner isa WilcoxonPruner
        test_pruner_basic(pruner)

        # Wilcoxon needs multiple steps to compare
        study, _ = create_test_study(; pruner=pruner)
        for i in 1:3
            trial = ask(study)
            for step in 0:5
                report(trial, Float64(i), step)
            end
            tell(study, trial, Float64(i))
        end
        trial = ask(study)
        for step in 0:5
            report(trial, 100.0, step)
        end
        @test_broken should_prune(trial) isa Bool
        tell(study, trial, 100.0)
    end
end
