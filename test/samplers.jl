#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

function create_test_study(sampler::Optuna.BaseSampler; name="test_study")
    test_dir = mktempdir()
    storage = RDBStorage(create_sqlite_url(test_dir, name))
    artifacts = FileSystemArtifactStore(joinpath(test_dir, "artifacts"))
    study = Study(name, artifacts, storage; sampler=sampler)
    return study, test_dir
end

function test_sampler(sampler::Optuna.BaseSampler)
    study, test_dir = create_test_study(sampler)

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

    rm(test_dir; recursive=true)
end

@testset "samplers" begin
    @testset "RandomSampler" begin
        sampler = RandomSampler(42)
        @test sampler isa RandomSampler
        test_sampler(sampler)
    end

    @testset "Fixed Seed reproducibility" begin
        # same seed should produce same suggestions
        results1 = Float64[]
        results2 = Float64[]

        for (results, seed) in [(results1, 123), (results2, 123)]
            sampler = RandomSampler(seed)
            study, test_dir = create_test_study(sampler; name="repro_test_$seed")
            for _ in 1:3
                trial = ask(study)
                push!(results, suggest_float(trial, "x", 0.0, 100.0))
                tell(study, trial, 1.0)
            end
            rm(test_dir; recursive=true)
        end

        @test results1 == results2
    end
end
