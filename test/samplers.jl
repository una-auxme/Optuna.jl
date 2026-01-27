#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

function test_sampler(sampler::Optuna.BaseSampler)
    study, test_dir = create_test_study(; sampler=sampler)

    # run a few trials and verify parameter suggestions work
    for _ in 1:3
        trial = ask(study)
        x = suggest_float(trial, "x", 0.0, 10.0)
        y = suggest_int(trial, "y", 1, 100)
        z = suggest_categorical(trial, "z", ["a", "b", "c"])

        @test 0.0 <= x <= 10.0
        @test 1 <= y <= 100
        @test z in ["a", "b", "c"]

        tell(study, trial, x + y)
    end

    cleanup_test_study(study, test_dir)

    return nothing
end

function test_sampler_reproducibility(sampler_constructor)
    # same seed should produce same suggestions
    # This should be tested upstream, but we convert the seed so its here as well
    results1 = Float64[]
    results2 = Float64[]
    seed = rand(UInt32)
    for (results, run) in [(results1, 1), (results2, 2)]
        sampler = sampler_constructor(seed)
        study, test_dir = create_test_study(; sampler=sampler, study_name="repro_test_$run")
        for _ in 1:3
            trial = ask(study)
            push!(results, suggest_float(trial, "x", 0.0, 100.0))
            tell(study, trial, 1.0)
        end
        cleanup_test_study(study, test_dir)
    end
    
    @test results1 == results2
    return nothing
end

@testset "samplers" begin
    @testset "RandomSampler" begin
        sampler = RandomSampler(42)
        @test sampler isa RandomSampler
        test_sampler(sampler)
        test_sampler_reproducibility(RandomSampler)
    end
end
