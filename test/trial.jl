#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

@testset "trial" begin
    @testset "suggest_int" begin
        study, test_dir = create_test_study(; study_name="suggest_int_test")
        trial = ask(study)

        x = suggest_int(trial, "x", typemin(Int), typemax(Int))
        @test x isa Int

        y = suggest_int(trial, "y", -100, 100)
        @test y isa Int
        @test -100 <= y <= 100

        # same name returns same value
        x2 = suggest_int(trial, "x", typemin(Int), typemax(Int))
        @test x == x2

        z1 = suggest_int(trial, "z1", -100, 100; step=10)
        @test z1 isa Int
        @test z1 % 10 == 0

        z2 = suggest_int(trial, "z2", 1, 100; log=true)
        @test z2 isa Int
        @test 1 <= z2 <= 100

        # low < 1 throws an error
        @test_throws Optuna.PythonCall.PyException suggest_int(
            trial, "err1", -100, 100; log=true
        )
        # step and log cannot be used at the same time
        @test_throws AssertionError suggest_int(trial, "err2", 10, 100; step=10, log=true)

        tell(study, trial, 1.0)
    end

    @testset "suggest_float" begin
        study, test_dir = create_test_study(; study_name="suggest_float_test")
        trial = ask(study)

        y = suggest_float(trial, "y", 1e-100, 1e100)
        @test y isa Float64

        x = suggest_float(trial, "x", -10.0, 10.0)
        @test x isa Float64
        @test -10.0 <= x <= 10.0

        @test_logs (:warn, r"Converting") x = suggest_float(trial, "x", -10.0f0, 10.0f0)
        x = @test x isa Float64

        # same name returns same value
        y2 = suggest_float(trial, "y", 1e-100, 1e100)
        @test y == y2

        z1 = suggest_float(trial, "z1", -100.0, 100.0; step=10.0)
        @test z1 isa Float64
        @test z1 % 10.0 == 0.0

        z2 = suggest_float(trial, "z2", 1.0, 1e100; log=true)
        @test z2 isa Float64
        @test 1.0 <= z2 <= 1e100

        # low <= 0 throws an error
        @test_throws Optuna.PythonCall.PyException suggest_float(
            trial, "err1", 0.0, 1e100; log=true
        )
        # step and log cannot be used at the same time
        @test_throws AssertionError suggest_float(
            trial, "err2", 1.0, 1e100; step=10.0, log=true
        )

        tell(study, trial, 1.0)
    end

    @testset "suggest_categorical" begin
        study, test_dir = create_test_study(; study_name="suggest_cat_test")
        trial = ask(study)

        # string choices
        z = suggest_categorical(trial, "z", ["a", "b", "c"])
        @test z isa String
        @test z in ["a", "b", "c"]

        # bool choices
        b = suggest_categorical(trial, "b", [true, false])
        @test b isa Bool

        # int choices
        i = suggest_categorical(trial, "i", [1, 2, 3])
        @test i isa Int
        @test i in [1, 2, 3]

        # float choices
        f = suggest_categorical(trial, "f", [-Inf, pi, 1e14])
        @test f isa AbstractFloat
        @test f in [-Inf, pi, 1e14]

        # choices as tuple
        ti = suggest_categorical(trial, "t", (1, 2, 3))
        @test ti isa Int
        @test ti in (1, 2, 3)

        tell(study, trial, 1.0)
    end

    @testset "report and should_prune" begin
        study, test_dir = create_test_study(;
            study_name="report_test", pruner=MedianPruner()
        )
        trial = ask(study)

        # report intermediate values
        report(trial, 1.0, 0)
        report(trial, 2.0, 1)

        # should_prune returns Bool
        @test should_prune(trial) isa Bool

        tell(study, trial, 1.0)
    end
end
