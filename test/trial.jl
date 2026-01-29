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

    @testset "suggest_int with different integer types" begin
        study, test_dir = create_test_study(; study_name="suggest_int_types_test")
        trial = ask(study)

        # Test with Int8 bounds - should still return Int
        i8 = suggest_int(trial, "i8", Int8(-10), Int8(10))
        @test i8 isa Int
        @test -10 <= i8 <= 10

        # Test with Int16 bounds - should still return Int
        i16 = suggest_int(trial, "i16", Int16(-100), Int16(100))
        @test i16 isa Int
        @test -100 <= i16 <= 100

        # Test with Int32 bounds - should still return Int
        i32 = suggest_int(trial, "i32", Int32(-1000), Int32(1000))
        @test i32 isa Int
        @test -1000 <= i32 <= 1000

        # Test with Int64 bounds - should return Int
        i64 = suggest_int(trial, "i64", Int64(-10000), Int64(10000))
        @test i64 isa Int
        @test -10000 <= i64 <= 10000

        # Test with Int8 bounds and Int step - should work and return Int
        i8_step = suggest_int(trial, "i8_step", Int8(-20), Int8(20); step=2)
        @test i8_step isa Int
        @test i8_step % 2 == 0

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

    @testset "suggest_float with Float32 bounds" begin
        study, test_dir = create_test_study(; study_name="suggest_float32_test")
        trial = ask(study)

        # Test with Float32 bounds - should return Float64 and warn (only once per parameter)
        local f32
        @test_logs (:warn, "Float32 bounds provided to suggest_float for parameter 'f32'. Return type will be Float64 to match Optuna's internal representation.") begin
            f32 = suggest_float(trial, "f32", Float32(-1.0), Float32(1.0))
            @test f32 isa Float64
            @test -1.0 <= f32 <= 1.0
        end

        # Call same parameter again - should not warn (returns same value)
        f32_2 = suggest_float(trial, "f32", Float32(-1.0), Float32(1.0))
        @test f32_2 isa Float64
        @test f32_2 == f32  # Same parameter returns same value

        # Test with Float32 bounds and Float32 step - should work and warn once
        @test_logs (:warn, "Float32 bounds provided to suggest_float for parameter 'f32_step'. Return type will be Float64 to match Optuna's internal representation.") begin
            f32_step = suggest_float(trial, "f32_step", Float32(-10.0), Float32(10.0); step=Float32(2.0))
            @test f32_step isa Float64
            @test f32_step % 2.0 == 0.0
        end

        # Test with Float64 bounds - should return Float64 without warning
        f64 = suggest_float(trial, "f64", -10.0, 10.0)
        @test f64 isa Float64
        @test -10.0 <= f64 <= 10.0

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
        i = suggest_categorical(trial, "f", [-Inf, pi, 1e14])
        @test i isa AbstractFloat
        @test i in [-Inf, pi, 1e14]

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
